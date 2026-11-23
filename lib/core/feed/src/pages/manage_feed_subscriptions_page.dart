// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../configs/manage/providers.dart';
import '../data/providers.dart';
import '../types/feed_subscription.dart';

/// Manages the followed queries of the news feed for the current booru
/// config: plain search strings, stored locally.
class FeedSubscriptionsPage extends ConsumerWidget {
  const FeedSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configId = ref.watch(
      currentBooruConfigProvider.select((value) => value.id),
    );
    final subscriptions =
        ref.watch(feedSubscriptionsNotifierProvider(configId)).valueOrNull ??
        const <FeedSubscription>[];

    return Scaffold(
      appBar: AppBar(title: Text(context.t.feed.manage)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Symbols.add),
        label: Text(context.t.feed.add_subscription),
        onPressed: () => _addSubscriptionDialog(context, ref, configId),
      ),
      body: subscriptions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.t.feed.empty,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];

                return Dismissible(
                  key: ValueKey('feed_subscription_${subscription.query}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(
                      Symbols.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) => ref
                      .read(
                        feedSubscriptionsNotifierProvider(configId).notifier,
                      )
                      .remove(subscription.query),
                  child: ListTile(
                    leading: const Icon(Symbols.search),
                    title: Text(subscription.query),
                    subtitle: subscription.lastCheckedAt != null
                        ? Text(
                            context.t.feed.last_checked(
                              time: TimeOfDay.fromDateTime(
                                subscription.lastCheckedAt!,
                              ).format(context),
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Symbols.delete),
                      onPressed: () => ref
                          .read(
                            feedSubscriptionsNotifierProvider(
                              configId,
                            ).notifier,
                          )
                          .remove(subscription.query),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    int configId,
  ) {
    final controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.feed.add_subscription),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.t.feed.query_hint,
            suffixIcon: IconButton(
              icon: const Icon(Symbols.check),
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text);
              },
            ),
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.t.generic.action.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(context.t.generic.action.add),
          ),
        ],
      ),
    ).then((value) {
      final query = value as String?;

      if (query != null && query.trim().isNotEmpty) {
        ref
            .read(feedSubscriptionsNotifierProvider(configId).notifier)
            .add(query.trim());
      }

      controller.dispose();
    });
  }
}
