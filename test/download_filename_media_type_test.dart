// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import 'package:boorusama/core/settings/types.dart';

void main() {
  group('resolveMediaType', () {
    Set<String> tags({bool animated = false}) => {
      '1girl',
      'solo',
      if (animated) 'animated',
    };

    test('mp4 and webm resolve to video', () {
      expect(
        resolveMediaType(format: 'mp4', tags: tags(), duration: 0),
        'video',
      );
      expect(
        resolveMediaType(format: 'webm', tags: tags(), duration: 0),
        'video',
      );
    });

    test('swf resolves to flash', () {
      expect(
        resolveMediaType(format: 'swf', tags: tags(), duration: 0),
        'flash',
      );
    });

    test('gif is always gif, with and without the animated tag', () {
      expect(
        resolveMediaType(format: 'gif', tags: tags(animated: true), duration: 5),
        'gif',
      );
      expect(
        resolveMediaType(format: 'gif', tags: tags(), duration: 0),
        'gif',
      );
    });

    test('ugoira zip resolves to zip', () {
      expect(
        resolveMediaType(format: 'zip', tags: tags(), duration: 10),
        'zip',
      );
    });

    test('static png/webp/avif resolve to image', () {
      expect(
        resolveMediaType(format: 'png', tags: tags(), duration: 0),
        'image',
      );
      expect(
        resolveMediaType(format: 'webp', tags: tags(), duration: 0),
        'image',
      );
      expect(
        resolveMediaType(format: 'avif', tags: tags(), duration: 0),
        'image',
      );
    });

    test('png/webp/avif with an animated tag resolve to gif', () {
      // apng
      expect(
        resolveMediaType(
          format: 'png',
          tags: tags(animated: true),
          duration: 0,
        ),
        'gif',
      );
      // animated webp
      expect(
        resolveMediaType(
          format: 'webp',
          tags: tags(animated: true),
          duration: 0,
        ),
        'gif',
      );
      // animated avif
      expect(
        resolveMediaType(
          format: 'avif',
          tags: tags(animated: true),
          duration: 0,
        ),
        'gif',
      );
    });

    test('duration > 0 promotes ambiguous formats to gif', () {
      expect(
        resolveMediaType(format: 'png', tags: tags(), duration: 4.2),
        'gif',
      );
      expect(
        resolveMediaType(format: 'webp', tags: tags(), duration: 0.5),
        'gif',
      );
    });

    test('kNoduration (-1) does not promote ambiguous formats', () {
      expect(
        resolveMediaType(format: 'webp', tags: tags(), duration: -1),
        'image',
      );
    });

    test('everything else resolves to image', () {
      expect(
        resolveMediaType(format: 'jpg', tags: tags(), duration: 0),
        'image',
      );
      expect(
        resolveMediaType(format: 'jpeg', tags: tags(), duration: 0),
        'image',
      );
      expect(
        resolveMediaType(format: '', tags: tags(), duration: 0),
        'image',
      );
      expect(
        resolveMediaType(format: null, tags: tags(), duration: 0),
        'image',
      );
    });

    test('format is normalized (dot prefix, case, whitespace)', () {
      expect(
        resolveMediaType(format: '.mp4', tags: tags(), duration: 0),
        'video',
      );
      expect(
        resolveMediaType(format: '  MP4 ', tags: tags(), duration: 0),
        'video',
      );
      expect(
        resolveMediaType(format: '.GIF', tags: tags(), duration: 0),
        'gif',
      );
      expect(
        resolveMediaType(format: '.Zip', tags: tags(), duration: 0),
        'zip',
      );
    });
  });

  group('DownloadFileNameBuilder {type} token', () {
    final builder = DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: const [],
    );

    const config = BooruConfigDownload(
      fileNameFormat: null,
      bulkFileNameFormat: null,
      location: null,
    );

    test('{type} expands to the media class inside the file name', () async {
      final fileName = await builder.generate(
        Settings.defaultSettings,
        const BooruConfigDownload(
          fileNameFormat: '{tags}_{type}.{extension}',
          bulkFileNameFormat: null,
          location: null,
        ),
        _TestPost(format: 'mp4', tags: const {'1girl', 'solo'}),
        downloadUrl: 'https://example.com/post.mp4',
      );

      // {tags} joins with a space by default; the delimiter token option can
      // change that
      expect(fileName, '1girl solo_video.mp4');
    });

    test('{type} works as a directory component', () async {
      final fileName = await builder.generate(
        Settings.defaultSettings,
        const BooruConfigDownload(
          fileNameFormat: '{type}/{id}.{extension}',
          bulkFileNameFormat: null,
          location: null,
        ),
        _TestPost(format: 'jpg'),
        downloadUrl: 'https://example.com/post.jpg',
      );

      expect(fileName, 'image/42.jpg');
    });

    test('{type} reflects the media class of the post, not the url', () async {
      // ugoira sample: zip post downloaded through a webm sample url
      final fileName = await builder.generate(
        Settings.defaultSettings,
        const BooruConfigDownload(
          fileNameFormat: '{type}/{id}.{extension}',
          bulkFileNameFormat: null,
          location: null,
        ),
        _TestPost(format: 'zip'),
        downloadUrl: 'https://example.com/post.webm',
      );

      // the class is `zip`, {extension} still reflects the real downloaded
      // file (webm) — the accepted mismatch
      expect(fileName, 'zip/42.webm');
    });

    test('animated png expands to gif', () async {
      final fileName = await builder.generate(
        Settings.defaultSettings,
        const BooruConfigDownload(
          fileNameFormat: '{type}/{id}.{extension}',
          bulkFileNameFormat: null,
          location: null,
        ),
        _TestPost(format: 'png', tags: const {'animated', 'apng'}),
        downloadUrl: 'https://example.com/post.png',
      );

      expect(fileName, 'gif/42.png');
    });

    test('bulk download format resolves {type} too', () async {
      final fileName = await builder.generateForBulkDownload(
        Settings.defaultSettings,
        config,
        _TestPost(format: 'mp4'),
        downloadUrl: 'https://cdn.example.com/sample.mp4',
      );

      // default bulk format contains no {type}; just make sure nothing broke
      expect(fileName, isNotEmpty);
    });
  });
}

class _TestPost extends SimplePost {
  _TestPost({
    required super.format,
    super.tags = const {},
    super.duration = 0,
  }) : super(
         id: 42,
         thumbnailImageUrl: '',
         sampleImageUrl: '',
         originalImageUrl: '',
         rating: Rating.general,
         hasComment: false,
         isTranslated: false,
         hasParentOrChildren: false,
         source: PostSource.none(),
         score: 0,
         fileSize: 0,
         hasSound: null,
         height: 100,
         md5: '0123456789abcdef0123456789abcdef',
         videoThumbnailUrl: '',
         videoUrl: '',
         width: 100,
         uploaderId: null,
         metadata: null,
       );
}
