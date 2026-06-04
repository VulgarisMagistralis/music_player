import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryParseToUri', () {
    Uri? parseToUri(String id) {
      try {
        final uri = Uri.parse(id);
        if (uri.isAbsolute) return uri;
      } catch (_) {}
      try {
        return Uri.file(id);
      } catch (_) {
        return null;
      }
    }

    test('parses absolute HTTP URI', () {
      final uri = parseToUri('https://example.com/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
    });

    test('parses absolute file URI', () {
      final uri = parseToUri('file:///storage/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'file');
    });

    test('parses relative path as file URI', () {
      final uri = parseToUri('/storage/emulated/0/Music/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'file');
    });

    test('parses Windows-style path as file URI', () {
      final uri = parseToUri('C:\\Music\\song.mp3');
      expect(uri, isNotNull);
    });

    test('handles empty string', () {
      final uri = parseToUri('');
      expect(uri, isNotNull);
    });

    test('parses content URI', () {
      final uri = parseToUri('content://media/audio/1');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'content');
    });
  });
}
