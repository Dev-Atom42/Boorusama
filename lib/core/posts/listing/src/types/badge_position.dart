// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

/// Which corner of a grid tile the file info badges
/// (source favicon / file format / resolution / file size) are anchored to.
enum BadgePosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  factory BadgePosition.parse(dynamic value) => switch (value) {
    'topLeft' || '0' || 0 => topLeft,
    'topRight' || '1' || 1 => topRight,
    'bottomLeft' || '2' || 2 => bottomLeft,
    'bottomRight' || '3' || 3 => bottomRight,
    _ => defaultValue,
  };

  static const BadgePosition defaultValue = topRight;

  bool get isTop => this == topLeft || this == topRight;
  bool get isLeft => this == topLeft || this == bottomLeft;

  dynamic toData() => index;

  String localize(BuildContext context) => switch (this) {
    topLeft => context.t.settings.appearance.badge_position_options.top_left,
    topRight => context.t.settings.appearance.badge_position_options.top_right,
    bottomLeft =>
      context.t.settings.appearance.badge_position_options.bottom_left,
    bottomRight =>
      context.t.settings.appearance.badge_position_options.bottom_right,
  };
}
