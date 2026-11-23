// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../configs/manage/providers.dart';
import '../../../errors/types.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/types.dart';
import '../data/providers.dart';
import '../logic/feed_logic.dart';
import '../routes/route_utils.dart';
import '../types/feed_subscription.dart';

/// An in-app feed of what is new for the queries the user follows, per booru
/// config. Runs on the regular post search API the app already uses - the
/// same parsers, no new endpoints, no Gold-account requirement like the
/// upstream Danbooru saved-search feed. v1 is manual-refresh only.
class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final searchConfig = ref.watchConfigSearch;
    final postRepo = ref.watch(postRepoProvider(searchConfig));
    final subscriptions =
        ref
            .watch(feedSubscriptionsNotifierProvider(booruConfig.id))
            .valueOrNull ??
        const <FeedSubscription>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.feed.title),
        actions: [
          IconButton(
            icon: const Icon(Symbols.feed),
            tooltip: context.t.feed.manage,
            onPressed: () => goToFeedSubscriptionsPage(ref),
          ),
        ],
      ),
      body: subscriptions.isEmpty
          ? _NoSubscriptionsView(
              onAdd: () => goToFeedSubscriptionsPage(ref),
            )
          : PostScope<Post>(
              fetcher: (page) => _fetchFeedPage(
                ref,
                booruConfig.id,
                postRepo,
                subscriptions,
                page,
              ),
              builder: (context, controller) => PostGrid<Post>(
                controller: controller,
                itemBuilder: (context, index, scrollController, hero) =>
                    DefaultImageGridItem<Post>(
                      index: index,
                      autoScrollController: scrollController,
                      controller: controller,
                      useHero: hero,
                      config: searchConfig.auth,
                    ),
              ),
            ),
    );
  }

  /// The feed is the newest items only; everything lives on page 1.
  /// The next page is always empty, so the grid stops paginating after the
  /// merged timeline.
  PostsOrErrorCore<Post> _fetchFeedPage(
    WidgetRef ref,
    int configId,
    PostRepository postRepo,
    List<FeedSubscription> subscriptions,
    int page,
  ) {
    if (page > 1) {
      return TaskEither.right(PostResult.empty());
    }

    return TaskEither(() async {
      final postsBySubscription = <FeedSubscription, List<Post>>{};
      final errors = <BooruError>[];

      for (final subscription in subscriptions) {
        final result = await postRepo.getPosts(subscription.query, 1).run();

        result.fold(
          errors.add,
          (value) => postsBySubscription[subscription] = value.posts,
        );
      }

      // units drive the pure feed logic: what is new, how to merge, how to
      // advance the cursors
      final units = [
        for (final entry in postsBySubscription.entries)
          FeedFetchUnit(
            subscription: entry.key,
            postIds: [
              for (final post in entry.value) post.id,
            ],
          ),
      ];

      // advance the per-subscription cursors for everything that succeeded,
      // so the next refresh only reports posts newer than what we just saw
      await _advanceCursors(ref, configId, units);

      // merge: per-subscription "new" filtering, dedupe by post id across
      // subscriptions, newest first, capped
      final mergedIds = mergedFeedIds(units, cap: kFeedCap);

      final postsById = <int, Post>{};

      for (final posts in postsBySubscription.values) {
        for (final post in posts) {
          postsById[post.id] ??= post;
        }
      }

      final posts = [
        for (final id in mergedIds)
          if (postsById[id] != null) postsById[id]!,
      ];

      if (posts.isEmpty && errors.isNotEmpty) {
        return Either.left(errors.first);
      }

      return Either.right(PostResult(posts: posts, total: posts.length));
    });
  }

  Future<void> _advanceCursors(
    WidgetRef ref,
    int configId,
    List<FeedFetchUnit> units,
  ) async {
    final provider = feedSubscriptionsNotifierProvider(configId);
    final current = await ref.read(provider.future);

    await ref
        .read(provider.notifier)
        .setSubscriptions(
          mergeSubscriptionUpdates(
            current,
            advanceCursors(units, DateTime.now()),
          ),
        );
  }
}

const kFeedCap = 200;

class _NoSubscriptionsView extends ConsumerWidget {
  const _NoSubscriptionsView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.feed,
            size: 48,
            color: Kurumi.themeOf(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(context.t.feed.empty, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onAdd,
            child: Text(context.t.feed.add_subscription),
          ),
        ],
      ),
    );
  }
}
