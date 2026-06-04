import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/media_item_converter.dart';

void main() {
  group('MediaItemConverter', () {
    test('fromJson returns null for null input', () {
      expect(const MediaItemConverter().fromJson(null), isNull);
    });

    test('fromJson returns null for missing id', () {
      expect(const MediaItemConverter().fromJson({'title': 'Test'}), isNull);
    });

    test('fromJson creates MediaItem with correct fields', () {
      final json = {'id': '/storage/song.mp3', 'title': 'Test Song', 'duration': 180000};
      final item = const MediaItemConverter().fromJson(json);

      expect(item, isNotNull);
      expect(item!.id, '/storage/song.mp3');
      expect(item.title, 'Test Song');
      expect(item.duration, const Duration(milliseconds: 180000));
    });

    test('fromJson handles missing duration', () {
      final json = {'id': '/storage/song.mp3', 'title': 'Test Song'};
      final item = const MediaItemConverter().fromJson(json);

      expect(item, isNotNull);
      expect(item!.duration, isNull);
    });

    test('fromJson handles zero duration', () {
      final json = {'id': '/storage/song.mp3', 'title': 'Test Song', 'duration': 0};
      final item = const MediaItemConverter().fromJson(json);

      expect(item, isNotNull);
      expect(item!.duration, const Duration(milliseconds: 0));
    });

    test('toJson returns null for null MediaItem', () {
      expect(const MediaItemConverter().toJson(null), isNull);
    });

    test('toJson serializes fields correctly', () {
      const item = MediaItem(id: '/storage/song.mp3', title: 'Test Song', duration: const Duration(milliseconds: 200000));
      final json = const MediaItemConverter().toJson(item);

      expect(json, isNotNull);
      expect(json!['id'], '/storage/song.mp3');
      expect(json['title'], 'Test Song');
      expect(json['duration'], 200000);
    });

    test('toJson handles null duration', () {
      const item = MediaItem(id: '/storage/song.mp3', title: 'Test Song');
      final json = const MediaItemConverter().toJson(item);

      expect(json, isNotNull);
      expect(json!['duration'], isNull);
    });

    test('round-trip fromJson to toJson preserves data', () {
      final originalJson = {'id': '/storage/song.mp3', 'title': 'Test Song', 'duration': 180000};
      const converter = MediaItemConverter();
      final item = converter.fromJson(originalJson);
      final serialized = converter.toJson(item);

      expect(serialized!['id'], originalJson['id']);
      expect(serialized['title'], originalJson['title']);
      expect(serialized['duration'], originalJson['duration']);
    });

    test('round-trip with null duration preserves null', () {
      final originalJson = {'id': '/storage/song.mp3', 'title': 'Test Song'};
      const converter = MediaItemConverter();
      final item = converter.fromJson(originalJson);
      final serialized = converter.toJson(item);

      expect(serialized!['duration'], isNull);
    });
  });
}
