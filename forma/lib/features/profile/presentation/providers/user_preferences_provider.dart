import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/storage/user_preferences_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_preferences_provider.g.dart';

/// Provides the current user's preferences from Hive.
///
/// Returns `null` if no preferences have been saved yet.
/// Hive is synchronous after initialization, so this provider
/// returns a plain [UserPreferencesModel?] without async/await.
@riverpod
UserPreferencesModel? userPreferences(UserPreferencesRef ref) {
  return HiveService.prefsBox.get('user');
}
