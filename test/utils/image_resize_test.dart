import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:music_player/utilities/image_resize.dart';

void main() {
  group('resizeAlbumArt', () {
    late Uint8List validPngBytes;

    setUp(() {
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(255, 0, 0));
      validPngBytes = Uint8List.fromList(img.encodePng(image));
    });

    test('returns resized image for valid PNG input', () {
      final result = resizeAlbumArt(validPngBytes);

      expect(result, isNotNull);
      expect(result.length, greaterThan(0));
      final decoded = img.decodePng(result);
      expect(decoded?.width, 50);
      expect(decoded?.height, 50);
    });

    test('returns original bytes for invalid image data', () {
      final invalidBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
      final result = resizeAlbumArt(invalidBytes);

      expect(result, invalidBytes);
    });

    test('returns original bytes for empty input', () {
      final empty = Uint8List(0);
      final result = resizeAlbumArt(empty);

      expect(result, empty);
    });

    test('returns original bytes for random garbage data', () {
      final garbage = Uint8List.fromList(List.generate(50, (i) => i % 256));
      final result = resizeAlbumArt(garbage);

      expect(result, garbage);
    });

    test('resizes larger images down to 50x50', () {
      final largeImage = img.Image(width: 500, height: 500);
      img.fill(largeImage, color: img.ColorRgb8(0, 255, 0));
      final largeBytes = Uint8List.fromList(img.encodePng(largeImage));

      final result = resizeAlbumArt(largeBytes);
      final decoded = img.decodePng(result);
      expect(decoded?.width, 50);
      expect(decoded?.height, 50);
    });

    test('resizes smaller images up to 50x50', () {
      final tinyImage = img.Image(width: 10, height: 10);
      img.fill(tinyImage, color: img.ColorRgb8(0, 0, 255));
      final tinyBytes = Uint8List.fromList(img.encodePng(tinyImage));

      final result = resizeAlbumArt(tinyBytes);
      final decoded = img.decodePng(result);
      expect(decoded?.width, 50);
      expect(decoded?.height, 50);
    });
  });
}
