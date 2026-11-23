// Dart imports:
import 'dart:io';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feed/providers.dart';
import 'package:boorusama/core/feed/types.dart';

void main() {
  late Directory tempDirectory;
  late FeedSubscriptionRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'feed_subscription_repository_test_',
    );
    Hive.init(tempDirectory.path);
    repository = FeedSubscriptionRepository(boxName: 'feed_test');
    await repository.init();
  });

  tearDown(() async {
    await repository.close();
    await tempDirectory.delete(recursive: true);
  });

  test('starts empty per config', () async {
    expect(repository.getSubscriptions(1), isEmpty);
    expect(repository.getSubscriptions(2), isEmpty);
  });

  test('add trims, ignores duplicates and empty queries', () async {
    await repository.addSubscription(1, '  genshin_impact solo  ');
    await repository.addSubscription(1, 'genshin_impact solo');
    await repository.addSubscription(1, '   ');
    await repository.addSubscription(2, 'another');

    expect(repository.getSubscriptions(1).single.query, 'genshin_impact solo');
    expect(repository.getSubscriptions(2).single.query, 'another');
  });

  test('remove deletes only the given query', () async {
    await repository.addSubscription(1, 'a');
    await repository.addSubscription(1, 'b');

    await repository.removeSubscription(1, 'a');

    expect(
      repository.getSubscriptions(1).single.query,
      'b',
    );
  });

  test('updateSubscriptions persists cursor state', () async {
    await repository.addSubscription(1, 'a');

    final updated = [
      const FeedSubscription(query: 'a', lastSeenPostId: 42),
    ];

    await repository.updateSubscriptions(1, updated);

    final restored = repository.getSubscriptions(1);

    expect(restored.single.lastSeenPostId, 42);
    expect(restored.single.lastCheckedAt, isNull);
  });

  test('configs are isolated from each other', () async {
    await repository.addSubscription(1, 'a');
    await repository.removeSubscription(2, 'a');

    expect(repository.getSubscriptions(1).single.query, 'a');
    expect(repository.getSubscriptions(2), isEmpty);
  });

  test('a corrupted payload resets to an empty list', () async {
    final box = await Hive.openBox<String>('feed_test');
    await box.put('config_1', 'not-a-json-list');

    expect(repository.getSubscriptions(1), isEmpty);
  });
}
