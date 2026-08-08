import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_tip_model.dart';
import '../repositories/health_repository.dart';

/// Provider that exposes the HealthRepository instance
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

/// AsyncNotifier that manages fetching and refreshing health tips.
/// Exposes AsyncValue<HealthTipModel> — loading, error, and data states.
class HealthTipNotifier extends AsyncNotifier<HealthTipModel> {
  @override
  Future<HealthTipModel> build() async {
    // Fetch a tip on first load
    return _fetch();
  }

  Future<HealthTipModel> _fetch() async {
    final repo = ref.read(healthRepositoryProvider);
    return repo.fetchRandomTip();
  }

  /// Refresh: fetches a new random tip from the API
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// Provider for the health tip notifier
final healthTipProvider =
    AsyncNotifierProvider<HealthTipNotifier, HealthTipModel>(() {
  return HealthTipNotifier();
});
