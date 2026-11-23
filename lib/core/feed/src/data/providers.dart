// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/feed_subscription.dart';
import 'feed_subscription_repository.dart';

final feedSubscriptionRepositoryProvider =
    FutureProvider<FeedSubscriptionRepository>((ref) async {
      final repository = FeedSubscriptionRepository();
      await repository.init();

      ref.onDispose(repository.close);

      return repository;
    });

/// Subscriptions of a booru config, keyed by the config id. Mutations
/// (add / remove / set) persist to the Hive box and refresh the state.
final feedSubscriptionsNotifierProvider =
    AsyncNotifierProvider.family<
      FeedSubscriptionsNotifier,
      List<FeedSubscription>,
      int
    >(
      FeedSubscriptionsNotifier.new,
    );

class FeedSubscriptionsNotifier
    extends FamilyAsyncNotifier<List<FeedSubscription>, int> {
  @override
  Future<List<FeedSubscription>> build(int configId) async {
    final repository = await ref.watch(
      feedSubscriptionRepositoryProvider.future,
    );

    return repository.getSubscriptions(configId);
  }

  Future<void> add(String query) async {
    await _mutate((repository) => repository.addSubscription(arg, query));
  }

  Future<void> remove(String query) async {
    await _mutate((repository) => repository.removeSubscription(arg, query));
  }

  /// Persists the given subscriptions for this config id as-is; used to
  /// advance the feed cursors after a refresh.
  Future<void> setSubscriptions(List<FeedSubscription> subscriptions) async {
    await _mutate(
      (repository) => repository.updateSubscriptions(arg, subscriptions),
    );
  }

  Future<void> _mutate(
    Future<void> Function(FeedSubscriptionRepository repository) action,
  ) async {
    final repository = await ref.read(
      feedSubscriptionRepositoryProvider.future,
    );

    await action(repository);

    ref.invalidateSelf();

    // surface the persisted list to awaiting readers
    await future;
  }
}
