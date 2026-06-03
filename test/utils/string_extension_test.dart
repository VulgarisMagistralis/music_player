import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/string_extension.dart';

void main() {
  group('StringExtension - capitalize', () {
    test('capitalizes first letter and lowercases rest', () {
      expect('hello'.capitalize(), 'Hello');
      expect('HELLO'.capitalize(), 'Hello');
      expect('hELLO'.capitalize(), 'Hello');
    });
  });

  group('StringExtension - beautifyFolderPath', () {
    test('converts internal storage path', () {
      expect(
        '/storage/emulated/0/Music'.beautifyFolderPath(),
        'Internal Storage/Music',
      );
    });

    test('converts SD card path', () {
      expect(
        '/storage/1234-5678/Music'.beautifyFolderPath(),
        'SD Card/Music',
      );
    });

    test('returns unchanged for other paths', () {
      expect('/mnt/extsd/Music'.beautifyFolderPath(), '/mnt/extsd/Music');
    });
  });

  group('StringExtension - camelCaseToSpaced', () {
    test('converts camelCase to spaced lowercase', () {
      expect('PlayerPageEnum'.camelCaseToSpaced, ' player page enum');
    });

    test('handles namespaced names', () {
      expect('my.package.MyClassName'.camelCaseToSpaced, ' my class name');
    });

    test('handles namespaced names', () {
      expect('my.package.MyClassName'.camelCaseToSpaced, ' my class name');
    });
  });

  group('StringExtension - reverseWordOrder', () {
    test('reverses word order', () {
      expect('hello world'.reverseWordOrder, 'world hello');
      expect('one two three'.reverseWordOrder, 'three two one');
    });

    test('handles extra whitespace', () {
      expect('  hello   world  '.reverseWordOrder, 'world hello');
    });

    test('handles single word', () {
      expect('hello'.reverseWordOrder, 'hello');
    });
  });
}
