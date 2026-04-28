import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/firebase_models.dart';

/// Thin local cache backed by shared_preferences.
/// Used to show stale data instantly while Firebase loads in the background.
class CacheService {
  static const _statsPrefix = 'daily_stats_';
  static const _userKey = 'cached_user';
  static const _onboardingKey = 'onboarding_complete';

  // ── Daily Stats ──────────────────────────────────────────────────────────

  static Future<void> saveDailyStats(DailyStatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsPrefix + stats.date, jsonEncode(stats.toFirestore()..['date'] = stats.date));
  }

  static Future<DailyStatsModel?> loadDailyStats(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsPrefix + date);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return DailyStatsModel(
      date: map['date'] ?? date,
      totalCalories: (map['totalCalories'] ?? 0).toDouble(),
      totalSpent: (map['totalSpent'] ?? 0).toDouble(),
      mealCount: map['mealCount'] ?? 0,
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fats: (map['fats'] ?? 0).toDouble(),
    );
  }

  // ── User / Settings ───────────────────────────────────────────────────────

  static Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(settings.toMap()));
  }

  static Future<UserSettings?> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserSettings.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── Onboarding flag ───────────────────────────────────────────────────────

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<void> clearOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}
