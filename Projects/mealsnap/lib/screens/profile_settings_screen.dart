import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/firebase_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _calorieGoalController = TextEditingController();
  final _budgetController = TextEditingController();

  final _dietaryOptions = {
    'vegetarian': 'Vegetarian',
    'vegan': 'Vegan',
    'low_carb': 'Low-Carb',
    'no_pork': 'No Pork',
    'pescatarian': 'Pescatarian',
  };

  final _cuisineOptions = {
    'african': 'African',
    'international': 'International',
    'comfort': 'Comfort',
    'low_calorie': 'Low-Calorie',
  };

  final _healthGoals = {
    'lose_weight': 'Lose Weight',
    'maintain': 'Maintain',
    'gain_muscle': 'Gain Muscle',
  };

  late final FirestoreService _firestoreService;
  UserModel? _user;
  bool _loading = true;
  bool _saving = false;
  String _profilePhotoUrl = '';
  String _healthGoal = 'maintain';
  List<String> _selectedPreferences = [];
  List<String> _selectedCuisines = [];

  String? _validateOptionalNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid $label';
    }
    if (parsed < 0) {
      return '$label cannot be negative';
    }
    return null;
  }

  String? _validateRequiredNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid $label';
    }
    if (parsed < 0) {
      return '$label cannot be negative';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _loadUserSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _calorieGoalController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final user = await _firestoreService.getUser(currentUser.uid);
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    _user = user;
    _profilePhotoUrl = user.photoUrl ?? '';
    _nameController.text = user.name;
    _ageController.text = user.settings.age?.toString() ?? '';
    _heightController.text = user.settings.height?.toString() ?? '';
    _currentWeightController.text = user.settings.currentWeight?.toString() ?? '';
    _targetWeightController.text = user.settings.targetWeight?.toString() ?? '';
    _calorieGoalController.text = user.settings.dailyCalorieGoal.toString();
    _budgetController.text = user.settings.monthlyBudget.toStringAsFixed(0);
    _healthGoal = user.settings.healthGoal;
    _selectedPreferences = List.from(user.settings.dietaryPreferences);
    _selectedCuisines = List.from(user.settings.preferredCuisines);

    setState(() {
      _loading = false;
    });
  }

  Future<void> _pickProfilePhoto() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (image == null) return;

    final file = File(image.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/${currentUser.uid}/profile_photo.jpg');

    setState(() {
      _saving = true;
    });

    try {
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      final displayName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (_user?.name ?? '');
      await _firestoreService.updateUserProfile(currentUser.uid, name: displayName, photoUrl: url);
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload photo: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    setState(() {
      _saving = true;
    });

    final newSettings = UserSettings(
      dailyCalorieGoal: int.tryParse(_calorieGoalController.text.trim()) ?? 2000,
      monthlyBudget: double.tryParse(_budgetController.text.trim()) ?? 100000,
      dietaryPreferences: _selectedPreferences,
      healthGoal: _healthGoal,
      preferredCuisines: _selectedCuisines.isNotEmpty
          ? List.from(_selectedCuisines)
          : ['african', 'international'],
      age: int.tryParse(_ageController.text.trim()),
      height: double.tryParse(_heightController.text.trim()),
      currentWeight: double.tryParse(_currentWeightController.text.trim()),
      targetWeight: double.tryParse(_targetWeightController.text.trim()),
    );

    try {
      await _firestoreService.updateUserSettings(currentUser.uid, newSettings);
      if (_nameController.text.trim().isNotEmpty && _nameController.text.trim() != _user?.name) {
        await AuthService.updateDisplayName(_nameController.text.trim());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile settings saved.')),
      );
      await _loadUserSettings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                            foregroundImage: _profilePhotoUrl.isNotEmpty
                                ? NetworkImage(_profilePhotoUrl)
                                : null,
                            child: _profilePhotoUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 48,
                                    color: colorScheme.primary,
                                  )
                                : null,
                          ),
                          InkWell(
                            onTap: _pickProfilePhoto,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.08 * 255).round()),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (value) => _validateOptionalNumber(value, 'age'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              prefixIcon: Icon(Icons.height),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (value) => _validateOptionalNumber(value, 'height'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _currentWeightController,
                            decoration: const InputDecoration(
                              labelText: 'Current weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (value) => _validateOptionalNumber(value, 'current weight'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _targetWeightController,
                            decoration: const InputDecoration(
                              labelText: 'Target weight (kg)',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (value) => _validateOptionalNumber(value, 'target weight'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daily Goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _calorieGoalController,
                      decoration: const InputDecoration(
                        labelText: 'Daily calorie goal',
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateRequiredNumber(value, 'daily calorie goal'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly food budget',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateRequiredNumber(value, 'monthly budget'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Health Goal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _healthGoals.entries.map((entry) {
                        final selected = _healthGoal == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _healthGoal = entry.key;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dietary Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dietaryOptions.entries.map((entry) {
                        return FilterChip(
                          label: Text(entry.value),
                          selected: _selectedPreferences.contains(entry.key),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPreferences.add(entry.key);
                              } else {
                                _selectedPreferences.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preferred Cuisines',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _cuisineOptions.entries.map((entry) {
                        return FilterChip(
                          label: Text(entry.value),
                          selected: _selectedCuisines.contains(entry.key),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCuisines.add(entry.key);
                              } else {
                                _selectedCuisines.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveSettings,
                        child: _saving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Profile Settings'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
