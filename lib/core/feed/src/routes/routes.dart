// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../router.dart';
import '../pages/feed_page.dart';
import '../pages/manage_feed_subscriptions_page.dart';

final feedRoutes = GoRoute(
  path: 'feed',
  name: '/feed',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => const FeedPage(),
  ),
  routes: [
    GoRoute(
      path: 'subscriptions',
      name: '/feed/subscriptions',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const FeedSubscriptionsPage(),
      ),
    ),
  ],
);
