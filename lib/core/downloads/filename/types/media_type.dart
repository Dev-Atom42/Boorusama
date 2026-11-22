// Resolves the `{type}` download filename token to a media class string:
// one of `image` / `gif` / `video` / `zip` / `flash`.
//
// The token is usable both as a directory and inside the file name:
//   - `{type}/{tags}`  -> saved into a folder named after the media class
//   - `{tags}_{type}.{extension}` -> e.g. `tags_video.jpg`
//
// Classification rules (final strings):
//   1. mp4 / webm -> `video` (unambiguous)
//   2. swf        -> `flash` (edge case)
//   3. gif        -> `gif` always (single-frame gifs are the accepted loss)
//   4. png / webp / avif -> `gif` when any signal says "animated"
//      (an `animated` tag present in the post's tags, or duration > 0),
//      otherwise `image`
//   5. zip        -> `zip` (ugoira frame archives are their own category:
//      the archive itself is what gets downloaded and stored)
//   6. everything else -> `image`
//
// Note: this deliberately does NOT reuse the core `isAnimated` mixin — it is
// format-based (`isFormatVideo || gif`) and misses animated png/webp/avif
// entirely. It does not reuse `isVideo` either — it counts ugoira zips as
// video. Missing signals are safe: tag/duration only promote ambiguous
// formats (png/webp/avif) from `image` to `gif`, so without them such a post
// falls back to `image` — a one-directional misclassification of a rare format
// class, mostly on self-hosted instances.

const kMediaTypeClasses = {'image', 'gif', 'video', 'zip', 'flash'};

/// A pure function over post fields (`format`, `tags`, `duration`) that every
/// booru implementation already has — no per-booru work, no new post fields.
String resolveMediaType({
  required String? format,
  required Set<String> tags,
  required double duration,
}) {
  final f = _normalizeFormat(format);

  switch (f) {
    case 'mp4':
    case 'webm':
      return 'video';
    case 'swf':
      return 'flash';
    case 'gif':
      return 'gif';
    case 'zip':
      return 'zip';
    case 'png':
    case 'webp':
    case 'avif':
      final isAnimated = tags.contains('animated') || duration > 0;

      return isAnimated ? 'gif' : 'image';
    default:
      return 'image';
  }
}

String _normalizeFormat(String? format) {
  if (format == null) return '';

  var f = format.toLowerCase().trim();
  if (f.startsWith('.')) f = f.substring(1);

  return f;
}
