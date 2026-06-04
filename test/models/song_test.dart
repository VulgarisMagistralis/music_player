import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/src/rust/api/data/song.dart';

void main() {
  group('Song', () {
    Song makeSong({BigInt? id, String path = '/storage/song.mp3', String title = 'Test Song', String artist = 'Artist', String album = 'Album', int lastModifiedAt = 1000, int? duration = 180, BigInt? albumArtId}) =>
        Song(id: id ?? BigInt.one, path: path, title: title, artist: artist, album: album, lastModifiedAt: lastModifiedAt, duration: duration, albumArtId: albumArtId);

    test('creates with required fields only', () {
      final minimal = Song(id: BigInt.zero, path: '/storage/song.mp3', title: 'Test Song', artist: 'Artist', album: 'Album', lastModifiedAt: 1000);

      expect(minimal.duration, isNull);
      expect(minimal.albumArtId, isNull);
    });

    test('equality works with all fields identical', () {
      final songA = makeSong();
      final clone = makeSong();

      expect(songA, clone);
    });

    test('inequality with different id', () {
      final songA = makeSong();
      final diff = makeSong(id: BigInt.two);

      expect(songA, isNot(diff));
    });

    test('inequality with different title', () {
      final songA = makeSong();
      final diff = makeSong(title: 'Different');

      expect(songA, isNot(diff));
    });

    test('inequality with different path', () {
      final songA = makeSong();
      final diff = makeSong(path: '/other/song.mp3');

      expect(songA, isNot(diff));
    });

    test('inequality with different duration', () {
      final songA = makeSong();
      final diff = makeSong(duration: 200);

      expect(songA, isNot(diff));
    });

    test('inequality with null vs non-null duration', () {
      final withDuration = makeSong(duration: 180);
      final withoutDuration = makeSong(duration: null);

      expect(withDuration, isNot(withoutDuration));
    });

    test('hashCode is consistent', () {
      final songA = makeSong();
      expect(songA.hashCode, songA.hashCode);
    });

    test('equal objects have same hashCode', () {
      final songA = makeSong(albumArtId: BigInt.two);
      final clone = makeSong(albumArtId: BigInt.two);

      expect(songA.hashCode, clone.hashCode);
    });
  });
}
