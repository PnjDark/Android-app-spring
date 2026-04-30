import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/firebase_models.dart';
import 'nutrition_database_service.dart';

/// Resolves a food name → verified NutritionInfo.
/// Layer order: FatSecret → Open Food Facts → local hardcoded DB.
/// AI is never involved here — this is the truth layer.
class NutritionApiService {
  // FatSecret OAuth2 client credentials
  // Register free at https://platform.fatsecret.com/api/
  static const _fatSecretTokenUrl =
      'https://oauth.fatsecret.com/connect/token';
  static const _fatSecretApiUrl = 'https://platform.fatsecret.com/rest/server.api';

  final String fatSecretClientId;
  final String fatSecretClientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  NutritionApiService({
    this.fatSecretClientId = '',
    this.fatSecretClientSecret = '',
  });

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Returns verified nutrition for [foodName] (per standard serving).
  /// Falls through layers silently — never throws to the caller.
  Future<ResolvedNutrition> resolve(String foodName) async {
    if (_isFatSecretConfigured()) {
      final result = await _fromFatSecret(foodName);
      if (result != null) return result;
    }

    final result = await _fromOpenFoodFacts(foodName);
    if (result != null) return result;

    return _fromLocalDb(foodName);
  }

  bool _isFatSecretConfigured() =>
      fatSecretClientId.isNotEmpty &&
      !fatSecretClientId.startsWith('<') &&
      fatSecretClientSecret.isNotEmpty &&
      !fatSecretClientSecret.startsWith('<');

  // ── FatSecret ────────────────────────────────────────────────────────────────

  Future<String?> _getFatSecretToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }
    try {
      final response = await http.post(
        Uri.parse(_fatSecretTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': fatSecretClientId,
          'client_secret': fatSecretClientSecret,
          'scope': 'basic',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String?;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 86400;
      _tokenExpiry =
          DateTime.now().add(Duration(seconds: expiresIn - 60));
      return _accessToken;
    } catch (_) {
      return null;
    }
  }

  Future<ResolvedNutrition?> _fromFatSecret(String foodName) async {
    try {
      final token = await _getFatSecretToken();
      if (token == null) return null;

      // Step 1: search for the food
      final searchResp = await http.get(
        Uri.parse(_fatSecretApiUrl).replace(queryParameters: {
          'method': 'foods.search',
          'search_expression': foodName,
          'format': 'json',
          'max_results': '1',
        }),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (searchResp.statusCode != 200) return null;
      final searchData =
          jsonDecode(searchResp.body) as Map<String, dynamic>;
      final foods = searchData['foods']?['food'];
      if (foods == null) return null;

      final food = foods is List ? foods.first : foods;
      final foodId = food['food_id']?.toString();
      if (foodId == null) return null;

      // Step 2: get full nutrition for that food_id
      final detailResp = await http.get(
        Uri.parse(_fatSecretApiUrl).replace(queryParameters: {
          'method': 'food.get.v4',
          'food_id': foodId,
          'format': 'json',
        }),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (detailResp.statusCode != 200) return null;
      final detailData =
          jsonDecode(detailResp.body) as Map<String, dynamic>;
      final servings =
          detailData['food']?['servings']?['serving'];
      if (servings == null) return null;

      final serving = servings is List ? servings.first : servings;
      return ResolvedNutrition(
        foodName: food['food_name']?.toString() ?? foodName,
        calories: _d(serving['calories']),
        proteinG: _d(serving['protein']),
        carbsG: _d(serving['carbohydrate']),
        fatG: _d(serving['fat']),
        fiberG: _d(serving['fiber']),
        sodiumMg: _d(serving['sodium']),
        servingDescription:
            serving['serving_description']?.toString() ?? '1 serving',
        source: NutritionSource.fatSecret,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Open Food Facts ──────────────────────────────────────────────────────────

  Future<ResolvedNutrition?> _fromOpenFoodFacts(String foodName) async {
    try {
      final encoded = Uri.encodeComponent(foodName);
      final response = await http.get(
        Uri.parse(
            'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=1'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>?;
      if (products == null || products.isEmpty) return null;

      final p = products.first as Map<String, dynamic>;
      final n = p['nutriments'] as Map<String, dynamic>?;
      if (n == null) return null;

      // OFF returns per 100g values
      return ResolvedNutrition(
        foodName: p['product_name']?.toString() ?? foodName,
        calories: _d(n['energy-kcal_100g'] ?? n['energy_100g']),
        proteinG: _d(n['proteins_100g']),
        carbsG: _d(n['carbohydrates_100g']),
        fatG: _d(n['fat_100g']),
        fiberG: _d(n['fiber_100g']),
        sodiumMg: (_d(n['sodium_100g'])) * 1000, // g → mg
        servingDescription: 'per 100 g',
        source: NutritionSource.openFoodFacts,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Local DB fallback ────────────────────────────────────────────────────────

  ResolvedNutrition _fromLocalDb(String foodName) {
    final info = NutritionDatabaseService.getNutritionInfo(foodName);
    if (info != null) {
      return ResolvedNutrition(
        foodName: foodName,
        calories: info.calories,
        proteinG: info.protein,
        carbsG: info.carbs,
        fatG: info.fat,
        fiberG: 0,
        sodiumMg: 0,
        servingDescription: 'per 100 g (estimated)',
        source: NutritionSource.localDb,
      );
    }
    return ResolvedNutrition.unknown(foodName);
  }

  double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
}

// ── Result model ─────────────────────────────────────────────────────────────

enum NutritionSource { fatSecret, openFoodFacts, localDb, unknown }

class ResolvedNutrition {
  final String foodName;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sodiumMg;
  final String servingDescription;
  final NutritionSource source;

  const ResolvedNutrition({
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sodiumMg,
    required this.servingDescription,
    required this.source,
  });

  factory ResolvedNutrition.unknown(String name) => ResolvedNutrition(
        foodName: name,
        calories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        fiberG: 0,
        sodiumMg: 0,
        servingDescription: 'unknown',
        source: NutritionSource.unknown,
      );

  NutritionInfo toNutritionInfo() => NutritionInfo(
        calories: calories,
        protein: proteinG,
        carbs: carbsG,
        fat: fatG,
      );

  String get sourceLabel => switch (source) {
        NutritionSource.fatSecret => 'FatSecret',
        NutritionSource.openFoodFacts => 'Open Food Facts',
        NutritionSource.localDb => 'Local DB',
        NutritionSource.unknown => 'Unknown',
      };

  bool get isVerified =>
      source == NutritionSource.fatSecret ||
      source == NutritionSource.openFoodFacts;
}
