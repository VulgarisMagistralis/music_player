import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/uint8_list_base64_converter.dart';

void main() {
  group('Uint8ListBase64Converter', () {
    const converter = Uint8ListBase64Converter();

    test('fromJson returns null for null input', () {
      expect(converter.fromJson(null), isNull);
    });

    test('fromJson decodes valid base64 string', () {
      final bytes = Uint8List.fromList([1, 2, 3, 255]);
      final encoded = base64Encode(bytes);
      final decoded = converter.fromJson(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.length, bytes.length);
      expect(decoded, equals(bytes));
    });

    test('toJson returns null for null input', () {
      expect(converter.toJson(null), isNull);
    });

    test('toJson encodes bytes to base64', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
      final encoded = converter.toJson(bytes);

      expect(encoded, isNotNull);
      expect(base64Decode(encoded!), equals(bytes));
    });

    test('round-trip preserves data', () {
      final original = Uint8List.fromList(List.generate(100, (i) => i % 256));
      final encoded = converter.toJson(original);
      final decoded = converter.fromJson(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.length, original.length);
      expect(decoded, equals(original));
    });

    test('handles empty byte list', () {
      final empty = Uint8List(0);
      final encoded = converter.toJson(empty);
      expect(encoded, '');
      expect(converter.fromJson(encoded), Uint8List(0));
    });
  });
}
