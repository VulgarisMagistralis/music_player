import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await SharedPreferenceWithCacheHandler.instance.init();
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AudioSessionManager', () {
    test('build returns initial state when no saved state', () {
      // Clear any existing saved state
      SharedPreferenceWithCacheHandler.instance.removeInteger('audio.session.last_song');
      
      final state = container.read(audioSessionManagerProvider);
      
      expect(state.isPlaying, isFalse);
      expect(state.isReady, isFalse);
      expect(state.playlistId, 'songs');
      expect(state.songId, isNull);
      expect(state.title, isNull);
    });

    test('updateState updates individual fields', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      await notifier.updateState(
        playlistId: 'favourites',
        title: 'Test Song',
        isPlaying: true,
        songIndexInPlaylist: 5,
      );
      
      final state = container.read(audioSessionManagerProvider);
      
      expect(state.playlistId, 'favourites');
      expect(state.title, 'Test Song');
      expect(state.isPlaying, isTrue);
      expect(state.songIndexInPlaylist, 5);
      expect(state.isReady, isFalse); // unchanged
    });

    test('updateState preserves unchanged fields', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      await notifier.updateState(
        playlistId: 'custom',
        isPlaying: true,
      );
      
      await notifier.updateState(
        title: 'New Title',
      );
      
      final state = container.read(audioSessionManagerProvider);
      
      expect(state.playlistId, 'custom'); // preserved
      expect(state.isPlaying, isTrue); // preserved
      expect(state.title, 'New Title'); // updated
    });

    test('updateFromMediaItem sets ready state', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      final mediaItem = MediaItem(
        id: '/path/to/song.mp3',
        title: 'Test Song',
        extras: {'songId': '42'},
      );
      
      notifier.updateFromMediaItem(mediaItem, 3);
      
      final state = container.read(audioSessionManagerProvider);
      
      expect(state.isReady, isTrue);
      expect(state.title, 'Test Song');
      expect(state.songId, BigInt.from(42));
      expect(state.songIndexInPlaylist, 3);
      expect(state.asMediaItem, isNotNull);
    });

    test('saveState persists state to shared preferences', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      await notifier.updateState(
        playlistId: 'favourites',
        title: 'Persisted Song',
        isPlaying: true,
      );
      
      await notifier.saveState();
      
      final savedState = SharedPreferenceWithCacheHandler.instance.loadSongState();
      
      expect(savedState, isNotNull);
      expect(savedState!.playlistId, 'favourites');
      expect(savedState.title, 'Persisted Song');
      expect(savedState.isPlaying, isTrue);
    });

    test('build loads saved state from shared preferences', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      // Save state first
      await notifier.updateState(
        playlistId: 'songs',
        title: 'Saved Song',
        isPlaying: false,
      );
      await notifier.saveState();
      
      // Create a new container to test loading from storage
      final newContainer = ProviderContainer();
      
      try {
        final loadedState = newContainer.read(audioSessionManagerProvider);
        
        expect(loadedState.title, 'Saved Song');
        expect(loadedState.playlistId, 'songs');
        expect(loadedState.isPlaying, isFalse);
      } finally {
        newContainer.dispose();
      }
    });

    test('updates persist across container recreation', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      await notifier.updateState(
        playlistId: 'test',
        title: 'Persistence Test',
        isPlaying: true,
      );
      
      // Create new container
      final newContainer = ProviderContainer();
      
      try {
        final state = newContainer.read(audioSessionManagerProvider);
        
        expect(state.playlistId, 'test');
        expect(state.title, 'Persistence Test');
        expect(state.isPlaying, isTrue);
      } finally {
        newContainer.dispose();
      }
    });

    test('updateState with partial updates', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      await notifier.updateState(playlistId: 'first');
      await notifier.updateState(title: 'A Title');
      await notifier.updateState(isPlaying: true);
      
      final state = container.read(audioSessionManagerProvider);
      
      expect(state.playlistId, 'first');
      expect(state.title, 'A Title');
      expect(state.isPlaying, isTrue);
    });

    test('handles null songId in updateFromMediaItem', () async {
      final notifier = container.read(audioSessionManagerProvider.notifier);
      
      final mediaItem = MediaItem(
        id: '/path/to/song.mp3',
        title: 'Test',
        extras: {'songId': 'invalid_id'}, // Not a valid BigInt
      );
      
      notifier.updateFromMediaItem(mediaItem, 0);
      
      final state = container.read(audioSessionManagerProvider);
      expect(state.songId, isNull);
      expect(state.title, 'Test');
      expect(state.isReady, isTrue);
    });
  });
}
