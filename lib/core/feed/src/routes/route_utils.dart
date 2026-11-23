// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../router.dart';

Future<void> goToFeedPage(WidgetRef ref) {
  return ref.router.push(
    Uri(path: '/feed').toString(),
  );
}

Future<void> goToFeedSubscriptionsPage(WidgetRef ref) {
  return ref.router.push(
    Uri(path: '/feed/subscriptions').toString(),
  );
}
