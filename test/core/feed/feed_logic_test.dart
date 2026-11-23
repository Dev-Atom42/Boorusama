// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feed/types.dart';

void main() {
  group('newPostIds', () {
    test('first run (no cursor) treats everything fetched as new', () {
      final unit = FeedFetchUnit(
        subscription: const FeedSubscription(query: 'genshin'),
        postIds: [10, 9, 8],
      );

      expect(newPostIds(unit), [10, 9, 8]);
    });

    test('filters down to ids newer than the cursor', () {
      final unit = FeedFetchUnit(
        subscription: const FeedSubscription(
          query: 'genshin',
          lastSeenPostId: 8,
        ),
        postIds: [10, 9, 8, 7],
      );

      expect(newPostIds(unit), [10, 9]);
    });
  });

  group('mergedFeedIds', () {
    test('merges subscriptions newest-first and dedupes by id', () {
      final units = [
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'a', lastSeenPostId: 90),
          postIds: [105, 101, 90],
        ),
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'b', lastSeenPostId: 95),
          postIds: [103, 101, 95],
        ),
      ];

      // a post matching two queries (101) shows up once
      expect(mergedFeedIds(units), [105, 103, 101]);
    });

    test('caps the merged timeline', () {
      final units = [
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'a'),
          postIds: List.generate(10, (i) => i),
        ),
      ];

      expect(mergedFeedIds(units, cap: 4).length, 4);
      // newest first
      expect(mergedFeedIds(units, cap: 4), [9, 8, 7, 6]);
    });
  });

  group('advanceCursors', () {
    final now = DateTime(2026, 1, 1);

    test('moves the cursor to the highest fetched id and stamps the time', () {
      final updated = advanceCursors([
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'a', lastSeenPostId: 8),
          postIds: [10, 9],
        ),
      ], now);

      expect(updated.single.query, 'a');
      expect(updated.single.lastSeenPostId, 10);
      expect(updated.single.lastCheckedAt, now);
    });

    test('never moves a cursor backwards', () {
      final updated = advanceCursors([
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'a', lastSeenPostId: 50),
          postIds: [10, 9],
        ),
      ], now);

      expect(updated.single.lastSeenPostId, 50);
    });

    test('failed and empty subscriptions are not advanced', () {
      final updated = advanceCursors([
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'a', lastSeenPostId: 8),
          postIds: const [],
          successful: false,
        ),
        FeedFetchUnit(
          subscription: const FeedSubscription(query: 'b', lastSeenPostId: 3),
          postIds: const [],
        ),
      ], now);

      expect(updated, isEmpty);
    });
  });

  group('mergeSubscriptionUpdates', () {
    test('keeps subscriptions without an update untouched', () {
      final current = const [
        FeedSubscription(query: 'a', lastSeenPostId: 1),
        FeedSubscription(query: 'b', lastSeenPostId: 2),
      ];

      final merged = mergeSubscriptionUpdates(current, [
        const FeedSubscription(query: 'a', lastSeenPostId: 99),
      ]);

      expect(merged.length, 2);
      expect(merged[0].lastSeenPostId, 99);
      expect(merged[1].lastSeenPostId, 2);
    });
  });

  group('FeedSubscription json round-trip', () {
    test('serializes and restores', () {
      final sub = FeedSubscription(
        query: 'genshin_impact solo',
        lastSeenPostId: 123456,
        lastCheckedAt: DateTime.utc(2026, 11, 20, 10, 30),
      );

      final restored = FeedSubscription.fromJson(sub.toJson());

      expect(restored.query, sub.query);
      expect(restored.lastSeenPostId, sub.lastSeenPostId);
      expect(restored.lastCheckedAt, sub.lastCheckedAt);
    });

    test('nulls survive the round-trip', () {
      const sub = FeedSubscription(query: 'a');

      final restored = FeedSubscription.fromJson(sub.toJson());

      expect(restored.lastSeenPostId, isNull);
      expect(restored.lastCheckedAt, isNull);
    });
  });
}
