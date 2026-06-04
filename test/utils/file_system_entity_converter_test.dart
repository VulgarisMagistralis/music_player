import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/file_system_entity_converter.dart';

void main() {
  group('FileSystemEntityConverter', () {
    const converter = FileSystemEntityConverter();

    test('fromJson returns null for null input', () {
      expect(converter.fromJson(null), isNull);
    });

    test('fromJson returns File for valid path', () {
      final entity = converter.fromJson('/storage/song.mp3');
      expect(entity, isNotNull);
      expect(entity, isA<File>());
      expect(entity!.path, '/storage/song.mp3');
    });

    test('toJson returns null for null input', () {
      expect(converter.toJson(null), isNull);
    });

    test('toJson returns path string', () {
      final file = File('/storage/song.mp3');
      expect(converter.toJson(file), '/storage/song.mp3');
    });

    test('round-trip preserves path', () {
      const path = '/storage/emulated/0/Music/test.mp3';
      final entity = converter.fromJson(path);
      final serialized = converter.toJson(entity);
      expect(serialized, path);
    });
  });
}
