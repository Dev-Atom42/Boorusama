// Package imports:
import 'package:equatable/equatable.dart';

/// A followed query of the news feed: a plain search string stored locally,
/// managed per booru config, plus the feed cursor state.
class FeedSubscription extends Equatable {
  const FeedSubscription({
    required this.query,
    this.lastSeenPostId,
    this.lastCheckedAt,
  });

  factory FeedSubscription.fromJson(Map<String, dynamic> json) =>
      FeedSubscription(
        query: json['query'] as String,
        lastSeenPostId: json['lastSeenPostId'] as int?,
        lastCheckedAt: json['lastCheckedAt'] == null
            ? null
            : DateTime.tryParse(json['lastCheckedAt'] as String),
      );

  /// The raw search string the user follows, e.g. `genshin_impact solo`.
  final String query;

  /// The highest post id already seen for this subscription. Posts with a
  /// greater id are "new" in the feed.
  final int? lastSeenPostId;

  /// When the feed last successfully checked this subscription.
  final DateTime? lastCheckedAt;

  FeedSubscription copyWith({
    String? query,
    int? lastSeenPostId,
    DateTime? lastCheckedAt,
  }) => FeedSubscription(
    query: query ?? this.query,
    lastSeenPostId: lastSeenPostId ?? this.lastSeenPostId,
    lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
  );

  Map<String, dynamic> toJson() => {
    'query': query,
    'lastSeenPostId': lastSeenPostId,
    'lastCheckedAt': lastCheckedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [query, lastSeenPostId, lastCheckedAt];
}
