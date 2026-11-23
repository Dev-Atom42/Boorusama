// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/listing/types.dart';
import 'package:boorusama/core/settings/types.dart';

void main() {
  group('ImageListingSettings file info badges', () {
    // A guaranteed-valid settings payload: the app's own defaults.
    Map<String, dynamic> baseJson() =>
        Settings.defaultSettings.listing.toJson();

    test('new badge flags default to false in the app defaults', () {
      final settings = Settings.defaultSettings.listing;

      expect(settings.showResolutionInGrid, isFalse);
      expect(settings.showFileSizeInGrid, isFalse);
      expect(settings.showSourceLogoInGrid, isFalse);
      expect(settings.showFileFormatInGrid, isFalse);
      expect(settings.fileInfoBadgePosition, BadgePosition.topRight);
    });

    test('new badge flags default to false when absent in stored json', () {
      final settings = ImageListingSettings.fromJson(baseJson());

      expect(settings.showResolutionInGrid, isFalse);
      expect(settings.showFileSizeInGrid, isFalse);
      expect(settings.showSourceLogoInGrid, isFalse);
      expect(settings.showFileFormatInGrid, isFalse);
      expect(settings.fileInfoBadgePosition, BadgePosition.topRight);
    });

    test('new badge flags round-trip through json', () {
      final json =
          ImageListingSettings.fromJson(
                baseJson(),
              )
              .copyWith(
                showResolutionInGrid: true,
                showFileSizeInGrid: true,
                showSourceLogoInGrid: true,
              )
              .toJson();

      expect(json['showResolutionInGrid'], isTrue);
      expect(json['showFileSizeInGrid'], isTrue);
      expect(json['showSourceLogoInGrid'], isTrue);

      final restored = ImageListingSettings.fromJson(json);
      expect(restored.showResolutionInGrid, isTrue);
      expect(restored.showFileSizeInGrid, isTrue);
      expect(restored.showSourceLogoInGrid, isTrue);
    });

    test('existing keys survive the round-trip', () {
      final json = ImageListingSettings.fromJson(baseJson()).toJson();

      expect(json['showScoresInGrid'], isFalse);
      expect(json['postsPerPage'], 60);

      final restored = ImageListingSettings.fromJson(json);
      expect(restored.gridSize, GridSize.normal);
      expect(restored.postsPerPage, 60);
      expect(restored.showScoresInGrid, isFalse);
    });

    test('copyWith keeps unspecified badge flags', () {
      final settings = ImageListingSettings.fromJson(
        baseJson()..['showSourceLogoInGrid'] = true,
      );

      final updated = settings.copyWith(showResolutionInGrid: true);

      expect(updated.showResolutionInGrid, isTrue);
      expect(updated.showSourceLogoInGrid, isTrue);
      expect(updated.showFileSizeInGrid, isFalse);
    });

    test('file format flag round-trips through json', () {
      final json =
          ImageListingSettings.fromJson(
            baseJson(),
          ).copyWith(showFileFormatInGrid: true).toJson();

      expect(json['showFileFormatInGrid'], isTrue);

      final restored = ImageListingSettings.fromJson(json);
      expect(restored.showFileFormatInGrid, isTrue);
    });

    test('badge position round-trips through json', () {
      final json =
          ImageListingSettings.fromJson(
            baseJson(),
          ).copyWith(
            fileInfoBadgePosition: BadgePosition.bottomLeft,
          ).toJson();

      // toData() persists the enum index, like PageIndicatorPosition.
      expect(json['fileInfoBadgePosition'], 2);

      final restored = ImageListingSettings.fromJson(json);
      expect(restored.fileInfoBadgePosition, BadgePosition.bottomLeft);
    });

    test('badge position parse accepts names, indices and junk', () {
      expect(BadgePosition.parse('topLeft'), BadgePosition.topLeft);
      expect(BadgePosition.parse('bottomRight'), BadgePosition.bottomRight);
      expect(BadgePosition.parse(0), BadgePosition.topLeft);
      expect(BadgePosition.parse(3), BadgePosition.bottomRight);
      expect(BadgePosition.parse('nope'), BadgePosition.topRight);
      expect(BadgePosition.parse(null), BadgePosition.topRight);
    });

    test('copyWith keeps unspecified format flag and position', () {
      final settings = ImageListingSettings.fromJson(
        baseJson()
          ..['showFileFormatInGrid'] = true
          ..['fileInfoBadgePosition'] = 3,
      );

      final updated = settings.copyWith(showResolutionInGrid: true);

      expect(updated.showFileFormatInGrid, isTrue);
      expect(updated.fileInfoBadgePosition, BadgePosition.bottomRight);
      expect(updated.showResolutionInGrid, isTrue);
    });
  });
}
