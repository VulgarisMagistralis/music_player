import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/route/routes.dart';

void main() {
  group('PlayerPageEnum.path', () {
    test('songs returns /songs', () {
      expect(PlayerPageEnum.songs.path, '/songs');
    });

    test('error returns /error', () {
      expect(PlayerPageEnum.error.path, '/error');
    });

    test('search returns /search', () {
      expect(PlayerPageEnum.search.path, '/search');
    });

    test('loading returns /loading', () {
      expect(PlayerPageEnum.loading.path, '/loading');
    });

    test('settings returns /settings', () {
      expect(PlayerPageEnum.settings.path, '/settings');
    });

    test('playlists returns /playlists', () {
      expect(PlayerPageEnum.playlists.path, '/playlists');
    });

    test('favourites returns /favourites', () {
      expect(PlayerPageEnum.favourites.path, '/favourites');
    });
  });

  group('PlayerPageEnum.playlistId', () {
    test('songs returns songs', () {
      expect(PlayerPageEnum.songs.playlistId, 'songs');
    });

    test('playlists returns /playlists', () {
      expect(PlayerPageEnum.playlists.playlistId, '/playlists');
    });

    test('favourites returns /favourites', () {
      expect(PlayerPageEnum.favourites.playlistId, '/favourites');
    });

    test('error returns songs as fallback', () {
      expect(PlayerPageEnum.error.playlistId, 'songs');
    });

    test('search returns songs as fallback', () {
      expect(PlayerPageEnum.search.playlistId, 'songs');
    });

    test('loading returns songs as fallback', () {
      expect(PlayerPageEnum.loading.playlistId, 'songs');
    });

    test('settings returns songs as fallback', () {
      expect(PlayerPageEnum.settings.playlistId, 'songs');
    });
  });

  group('PlayerPageEnum.toTitle', () {
    test('capitalizes each page name', () {
      expect(PlayerPageEnum.songs.toTitle(), 'Songs');
      expect(PlayerPageEnum.error.toTitle(), 'Error');
      expect(PlayerPageEnum.search.toTitle(), 'Search');
      expect(PlayerPageEnum.loading.toTitle(), 'Loading');
      expect(PlayerPageEnum.settings.toTitle(), 'Settings');
      expect(PlayerPageEnum.playlists.toTitle(), 'Playlists');
      expect(PlayerPageEnum.favourites.toTitle(), 'Favourites');
    });
  });
}
