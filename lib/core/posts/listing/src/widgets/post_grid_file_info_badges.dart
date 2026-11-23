// Package imports:
import 'package:foundation/foundation.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../config_widgets/website_logo.dart';
import '../../../post/types.dart';
import '../../../sources/types.dart';
import '../types/badge_position.dart';

/// Compact file info badges (source favicon / file format / resolution /
/// file size) shown on main grid tiles, ported from the related-posts
/// preview tiles.
///
/// Purely informational: wrapped in [IgnorePointer] by the caller so it
/// never intercepts tile taps.
class PostGridFileInfoBadges extends StatelessWidget {
  const PostGridFileInfoBadges({
    required this.post,
    super.key,
    this.showSourceLogo = false,
    this.showResolution = false,
    this.showFileSize = false,
    this.showFileFormat = false,
    this.position = BadgePosition.defaultValue,
    this.compact = false,
  });

  final Post post;

  /// Whether to show the favicon of the post's web source.
  final bool showSourceLogo;

  /// Whether to show the `WxH` resolution badge.
  final bool showResolution;

  /// Whether to show the parsed file size badge.
  final bool showFileSize;

  /// Whether to show the file extension badge (png / jpg / mp4 ...).
  final bool showFileFormat;

  /// Which corner of the tile the badge stack is anchored to.
  final BadgePosition position;

  /// Hides the text badges (resolution / file size) on tiny grid sizes
  /// where they would not fit; the source favicon stays.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final format = _fileExtension(post.format);

    final badges = <Widget>[
      if (showSourceLogo)
        post.source.whenWeb(
          (source) => _Badge(
            child: ConfigAwareWebsiteLogo(url: source.url),
          ),
          () => const SizedBox.shrink(),
        ),
      if (showFileFormat && !compact && format != null)
        _Badge(
          child: _BadgeText(format),
        ),
      if (showResolution && !compact)
        _Badge(
          child: _BadgeText('${post.width.toInt()}x${post.height.toInt()}'),
        ),
      if (showFileSize && !compact && post.fileSize > 0)
        _Badge(
          child: _BadgeText(Filesize.parse(post.fileSize, round: 1)),
        ),
    ].where((widget) => widget is! SizedBox).toList();

    if (badges.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: position.isLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: badges,
      ),
    );
  }
}

/// Normalizes a post `format` field (`png`, `.MP4`, ...) into a short
/// extension label; returns null when the booru sent nothing usable, in
/// which case the badge is skipped entirely.
String? _fileExtension(String format) {
  var f = format.trim().toLowerCase();
  if (f.startsWith('.')) f = f.substring(1);

  return f.isEmpty ? null : f;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(compactBadgePadding),
      decoration: BoxDecoration(
        color: context.extendedColorScheme.surfaceContainerOverlay,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: child,
    );
  }
}

class _BadgeText extends StatelessWidget {
  const _BadgeText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: compactBadgeFontSize,
        fontWeight: FontWeight.bold,
        color: context.extendedColorScheme.onSurfaceContainerOverlay,
      ),
    );
  }
}

// Phone-sized tiles need smaller badges than the related-posts preview.
const compactBadgePadding = 3.0;
const compactBadgeFontSize = 10.0;
