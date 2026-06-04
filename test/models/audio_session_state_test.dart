import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/audio_session_state.dart';

void main() {
  group('AudioSessionState', () {
    test('creates with defaults', () {
      const state = AudioSessionState();

      expect(state.playlistId, 'songs');
      expect(state.songId, isNull);
      expect(state.file, isNull);
      expect(state.title, isNull);
      expect(state.songIndexInPlaylist, 0);
      expect(state.isPlaying, isFalse);
      expect(state.isReady, isFalse);
      expect(state.playlistScrollOffset, 0.0);
      expect(state.albumArt, isNull);
      expect(state.asMediaItem, isNull);
      expect(state.favouritePlaylistIndexOrNull, isNull);
    });

    test('initial factory produces default state', () {
      final state = AudioSessionState.initial();

      expect(state.playlistId, 'songs');
      expect(state.isPlaying, isFalse);
      expect(state.isReady, isFalse);
    });

    test('creates with custom values', () {
      const state = AudioSessionState(playlistId: 'custom', songIndexInPlaylist: 5, isPlaying: true, title: 'Test Song');

      expect(state.playlistId, 'custom');
      expect(state.songIndexInPlaylist, 5);
      expect(state.isPlaying, isTrue);
      expect(state.title, 'Test Song');
    });

    test('fromJson round-trip with minimal fields', () {
      const original = AudioSessionState(playlistId: 'favourites', songIndexInPlaylist: 3, isPlaying: true);
      final json = original.toJson();
      final deserialized = AudioSessionState.fromJson(json);

      expect(deserialized.playlistId, original.playlistId);
      expect(deserialized.songIndexInPlaylist, original.songIndexInPlaylist);
      expect(deserialized.isPlaying, original.isPlaying);
      expect(deserialized.isReady, original.isReady);
    });

    test('fromJson with null optional fields', () {
      final json = {'playlistId': 'songs', 'songIndexInPlaylist': 0, 'isPlaying': false, 'isReady': false, 'playlistScrollOffset': 0.0, 'favouritePlaylistIndexOrNull': null};
      final state = AudioSessionState.fromJson(json);

      expect(state.playlistId, 'songs');
      expect(state.songId, isNull);
      expect(state.title, isNull);
      expect(state.favouritePlaylistIndexOrNull, isNull);
    });

    test('equality works correctly', () {
      const a = AudioSessionState(playlistId: 'songs', isPlaying: true);
      const b = AudioSessionState(playlistId: 'songs', isPlaying: true);
      const c = AudioSessionState(playlistId: 'songs', isPlaying: false);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith modifies selected fields', () {
      const original = AudioSessionState();
      final modified = original.copyWith(isPlaying: true, title: 'New Song');

      expect(modified.isPlaying, isTrue);
      expect(modified.title, 'New Song');
      expect(modified.playlistId, original.playlistId);
      expect(modified.isReady, original.isReady);
    });

    test('hashCode is consistent', () {
      const state = AudioSessionState(playlistId: 'songs', isPlaying: true);
      expect(state.hashCode, state.hashCode);
    });
  });
}
