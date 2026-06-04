import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/playlist.dart';

void main() {
  group('Playlist', () {
    test('creates with id only', () {
      const playlist = Playlist(id: 'test-id');

      expect(playlist.id, 'test-id');
      expect(playlist.name, 'Playlist');
      expect(playlist.songIdList, isEmpty);
    });

    test('creates with custom name', () {
      const playlist = Playlist(id: 'test-id', name: 'My Favorites');

      expect(playlist.id, 'test-id');
      expect(playlist.name, 'My Favorites');
      expect(playlist.songIdList, isEmpty);
    });

    test('creates with song list', () {
      const playlist = Playlist(id: 'test-id', songIdList: ['song1', 'song2', 'song3']);

      expect(playlist.id, 'test-id');
      expect(playlist.name, 'Playlist');
      expect(playlist.songIdList, hasLength(3));
    });

    test('Playlist.create generates new UUID', () {
      final playlist = Playlist.create(id: 'ignored-id', name: 'Test', songIdList: []);

      expect(playlist.name, 'Test');
      expect(playlist.songIdList, isEmpty);
    });

    test('Playlist.create ignores passed id', () {
      final playlist = Playlist.create(id: 'original-id', name: 'Test', songIdList: []);

      expect(playlist.id, isNot('original-id'));
    });

    test('Playlist.create generates unique IDs', () {
      final p1 = Playlist.create(id: 'id', name: 'p1', songIdList: []);
      final p2 = Playlist.create(id: 'id', name: 'p2', songIdList: []);

      expect(p1.id, isNot(p2.id));
    });

    test('fromJson serializes and deserializes correctly', () {
      const original = Playlist(id: 'test-id', name: 'Rock Songs', songIdList: ['a', 'b', 'c']);
      final json = original.toJson();
      final deserialized = Playlist.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.songIdList, original.songIdList);
    });

    test('fromJson handles empty song list', () {
      const original = Playlist(id: 'test-id');
      final json = original.toJson();
      final deserialized = Playlist.fromJson(json);

      expect(deserialized.id, 'test-id');
      expect(deserialized.name, 'Playlist');
      expect(deserialized.songIdList, isEmpty);
    });

    test('equality works correctly', () {
      const a = Playlist(id: '1', name: 'Same', songIdList: ['x']);
      const b = Playlist(id: '1', name: 'Same', songIdList: ['x']);
      const c = Playlist(id: '2', name: 'Same', songIdList: ['x']);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith creates modified copy', () {
      const original = Playlist(id: '1', name: 'Original');
      final modified = original.copyWith(name: 'Modified');

      expect(modified.id, original.id);
      expect(modified.name, 'Modified');
      expect(modified.songIdList, original.songIdList);
    });
  });
}
