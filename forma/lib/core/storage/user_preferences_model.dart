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

  static const Object _sentinel = Object();

  UserPreferencesModel copyWith({
    Object? isPremium = _sentinel,
    Object? premiumReceiptData = _sentinel,
    Object? hasCompletedOnboarding = _sentinel,
    Object? themeIndex = _sentinel,
    Object? name = _sentinel,
    Object? joinDate = _sentinel,
  }) {
    return UserPreferencesModel(
      isPremium: isPremium == _sentinel ? this.isPremium : isPremium as bool,
      premiumReceiptData: premiumReceiptData == _sentinel
          ? this.premiumReceiptData
          : premiumReceiptData as String?,
      hasCompletedOnboarding: hasCompletedOnboarding == _sentinel
          ? this.hasCompletedOnboarding
          : hasCompletedOnboarding as bool,
      themeIndex: themeIndex == _sentinel ? this.themeIndex : themeIndex as int,
      name: name == _sentinel ? this.name : name as String,
      joinDate: joinDate == _sentinel ? this.joinDate : joinDate as DateTime,
    );
  }
}
