import 'package:forma/core/storage/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_status_provider.g.dart';

/// Reads the user's premium status from Hive.
///
/// Returns `true` if the user has an active premium subscription,
/// `false` otherwise. Hive is synchronous after initialization,
/// so this provider returns a plain [bool] without async/await.
@riverpod
bool premiumStatus(PremiumStatusRef ref) {
  final box = HiveService.prefsBox;
  final prefs = box.get('user');
  return prefs?.isPremium ?? false;
}
