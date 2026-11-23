// Package imports:
import 'dart:convert';

import 'package:hive_ce/hive.dart';

// Project imports:
import '../types/feed_subscription.dart';

/// Local storage for the news feed subscriptions, one list per booru config
/// (Hive, like other per-config data).
///
/// Stored as a JSON-encoded list under the config id, so the box stays
/// schema-free and new subscription fields can be added without a Hive
/// adapter migration.
class FeedSubscriptionRepository {
  FeedSubscriptionRepository({String boxName = 'feed_subscriptions'})
    : _boxName = boxName;

  final String _boxName;
  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  List<FeedSubscription> getSubscriptions(int configId) {
    final raw = _box?.get(_key(configId));

    if (raw == null) return const [];

    try {
      final json = jsonDecode(raw) as List<dynamic>;

      return [
        for (final entry in json)
          if (entry is Map<String, dynamic>) FeedSubscription.fromJson(entry),
      ];
    } catch (_) {
      // corrupted payload: reset to an empty list rather than crash the feed
      return const [];
    }
  }

  Future<void> addSubscription(int configId, String query) async {
    final queryNormalized = query.trim();

    if (queryNormalized.isEmpty) return;

    final subs = getSubscriptions(configId);

    if (subs.any((sub) => sub.query == queryNormalized)) return;

    await _save(configId, [
      ...subs,
      FeedSubscription(query: queryNormalized),
    ]);
  }

  Future<void> removeSubscription(int configId, String query) async {
    await _save(
      configId,
      getSubscriptions(configId).where((sub) => sub.query != query).toList(),
    );
  }

  Future<void> updateSubscriptions(
    int configId,
    List<FeedSubscription> subscriptions,
  ) => _save(configId, subscriptions);

  Future<void> _save(int configId, List<FeedSubscription> subs) async {
    final payload = jsonEncode([
      for (final sub in subs)
        if (sub.query.trim().isNotEmpty) sub.toJson(),
    ]);

    await _box?.put(_key(configId), payload);
  }

  String _key(int configId) => 'config_$configId';
}
