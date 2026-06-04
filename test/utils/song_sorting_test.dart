import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/utilities/song_sorting.dart';

Song _makeSong({BigInt? id, String title = '', int? duration, int lastModifiedAt = 0, String path = '', String artist = '', String album = '', BigInt? albumArtId}) {
  return Song(id: id ?? BigInt.zero, title: title, duration: duration, lastModifiedAt: lastModifiedAt, path: path, artist: artist, album: album, albumArtId: albumArtId);
}

void main() {
  group('sortSongList', () {
    test('sorts by name ascending', () {
      final songs = [_makeSong(title: 'Charlie'), _makeSong(title: 'Alpha'), _makeSong(title: 'Bravo')];
      sortSongList(songs, SortBy.nameAscending);
      expect(songs.map((s) => s.title).toList(), ['Alpha', 'Bravo', 'Charlie']);
    });

    test('sorts by name descending', () {
      final songs = [_makeSong(title: 'Charlie'), _makeSong(title: 'Alpha'), _makeSong(title: 'Bravo')];
      sortSongList(songs, SortBy.nameDescending);
      expect(songs.map((s) => s.title).toList(), ['Charlie', 'Bravo', 'Alpha']);
    });

    test('sorts by duration ascending', () {
      final songs = [_makeSong(duration: 300), _makeSong(duration: 60), _makeSong(duration: 180)];
      sortSongList(songs, SortBy.durationAscending);
      expect(songs.map((s) => s.duration).toList(), [60, 180, 300]);
    });

    test('sorts by duration descending', () {
      final songs = [_makeSong(duration: 300), _makeSong(duration: 60), _makeSong(duration: 180)];
      sortSongList(songs, SortBy.durationDescending);
      expect(songs.map((s) => s.duration).toList(), [300, 180, 60]);
    });

    test('handles null duration treating it as 0', () {
      final songs = [_makeSong(duration: 180), _makeSong(duration: null), _makeSong(duration: 60)];
      sortSongList(songs, SortBy.durationAscending);
      expect(songs.map((s) => s.duration).toList(), [null, 60, 180]);
    });

    test('sorts by date modified ascending', () {
      final songs = [_makeSong(lastModifiedAt: 3000), _makeSong(lastModifiedAt: 1000), _makeSong(lastModifiedAt: 2000)];
      sortSongList(songs, SortBy.dateModifiedAscending);
      expect(songs.map((s) => s.lastModifiedAt).toList(), [1000, 2000, 3000]);
    });

    test('sorts by date modified descending', () {
      final songs = [_makeSong(lastModifiedAt: 3000), _makeSong(lastModifiedAt: 1000), _makeSong(lastModifiedAt: 2000)];
      sortSongList(songs, SortBy.dateModifiedDescending);
      expect(songs.map((s) => s.lastModifiedAt).toList(), [3000, 2000, 1000]);
    });

    test('handles empty list', () {
      final songs = <Song>[];
      sortSongList(songs, SortBy.nameAscending);
      expect(songs, isEmpty);
    });

    test('handles single element', () {
      final songs = [_makeSong(title: 'Only')];
      sortSongList(songs, SortBy.nameAscending);
      expect(songs.length, 1);
      expect(songs.first.title, 'Only');
    });
  });

  group('SortSongs extension', () {
    test('sortBy sorts in place', () {
      final songs = [_makeSong(title: 'Charlie'), _makeSong(title: 'Alpha')];
      songs.sortBy(SortBy.nameAscending);
      expect(songs[0].title, 'Alpha');
      expect(songs[1].title, 'Charlie');
    });

    test('sortedBy returns new list without mutating original', () {
      final songs = [_makeSong(title: 'Charlie'), _makeSong(title: 'Alpha')];
      final sorted = songs.sortedBy(SortBy.nameAscending);
      expect(sorted[0].title, 'Alpha');
      expect(sorted[1].title, 'Charlie');
      expect(songs[0].title, 'Charlie');
      expect(songs[1].title, 'Alpha');
    });
  });
}
