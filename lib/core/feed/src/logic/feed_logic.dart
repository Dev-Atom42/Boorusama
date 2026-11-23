// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../types/feed_subscription.dart';

/// The per-subscription results of one feed refresh.
class FeedFetchUnit extends Equatable {
  const FeedFetchUnit({
    required this.subscription,
    required this.postIds,
    this.successful = true,
  });

  /// The subscription the posts were fetched for.
  final FeedSubscription subscription;

  /// Numeric post ids fetched for this subscription, newest-first page as
  /// returned by the search API.
  final List<int> postIds;

  /// Whether the search for this subscription succeeded. Failed
  /// subscriptions contribute no posts and keep their cursor untouched.
  final bool successful;

  @override
  List<Object?> get props => [subscription, postIds, successful];
}

/// Filters a subscription's fetched ids down to the "new" ones: posts newer
/// than the stored last-seen cursor. On the very first run (no cursor yet)
/// everything fetched counts as new, so the feed bootstraps with a page of
/// results and the cursor is armed for the next refresh.
List<int> newPostIds(FeedFetchUnit unit) {
  final cursor = unit.subscription.lastSeenPostId;

  if (cursor == null) return List.of(unit.postIds);

  return unit.postIds.where((id) => id > cursor).toList();
}

/// Merges the new ids of all subscriptions into a single newest-first
/// timeline, deduplicated by post id (a post matching two queries shows up
/// once) and capped so a feed of many subscriptions stays responsive.
List<int> mergedFeedIds(List<FeedFetchUnit> units, {int cap = 200}) {
  final merged = <int>{};

  for (final unit in units) {
    merged.addAll(newPostIds(unit));
  }

  final ids = merged.toList()..sort((a, b) => b.compareTo(a));

  return ids.length > cap ? ids.sublist(0, cap) : ids;
}

/// The next cursor state per subscription query after a successful refresh:
/// lastSeenPostId moves to the highest id fetched for that subscription
/// (not just the ones shown), lastCheckedAt to now.
List<FeedSubscription> advanceCursors(
  List<FeedFetchUnit> units,
  DateTime now,
) => [
  for (final unit in units)
    if (unit.successful && unit.postIds.isNotEmpty)
      unit.subscription.copyWith(
        lastSeenPostId: unit.postIds.fold<int>(
          unit.subscription.lastSeenPostId ?? 0,
          (acc, id) => id > acc ? id : acc,
        ),
        lastCheckedAt: now,
      ),
];

/// Keeps failed or empty-handed subscriptions in the list unchanged, so
/// their cursor is not lost on a partial refresh.
List<FeedSubscription> mergeSubscriptionUpdates(
  List<FeedSubscription> current,
  List<FeedSubscription> updated,
) {
  final updatedByQuery = {
    for (final sub in updated) sub.query: sub,
  };

  return [
    for (final sub in current) updatedByQuery[sub.query] ?? sub,
  ];
}
