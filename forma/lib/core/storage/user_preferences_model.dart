import 'package:hive_flutter/hive_flutter.dart';

part 'user_preferences_model.g.dart';

/// Hive model for storing user preferences.
///
/// This class is used for serializing/deserializing user preferences to/from local storage.
/// Type ID: 4 (per ARCHITECTURE.md §7)
@HiveType(typeId: 4)
class UserPreferencesModel extends HiveObject {
  UserPreferencesModel({
    this.isPremium = false,
    this.premiumReceiptData,
    this.hasCompletedOnboarding = false,
    this.themeIndex = 0,
    this.name = '',
    required this.joinDate,
  });

  @HiveField(0)
  final bool isPremium;

  @HiveField(1)
  final String? premiumReceiptData;

  @HiveField(2)
  final bool hasCompletedOnboarding;

  @HiveField(3)
  final int themeIndex;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final DateTime joinDate;

  UserPreferencesModel copyWith({
    bool? isPremium,
    String? premiumReceiptData,
    bool? hasCompletedOnboarding,
    int? themeIndex,
    String? name,
    DateTime? joinDate,
  }) {
    return UserPreferencesModel(
      isPremium: isPremium ?? this.isPremium,
      premiumReceiptData: premiumReceiptData ?? this.premiumReceiptData,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themeIndex: themeIndex ?? this.themeIndex,
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}