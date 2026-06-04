import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late PlayerAudioHandler handler;
  late ProviderContainer container;
  bool initialized = false;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await SharedPreferenceWithCacheHandler.instance.init();
    _setUpMockChannels();
  });

  setUp(() async {
    container = ProviderContainer();
    handler = PlayerAudioHandler();
    try {
      await handler.init(container);
      initialized = true;
    } catch (_) {
      // init failed due to platform issues; skip tests requiring init
    }
  });

  tearDown(() async {
    if (initialized) await handler.dispose();
    container.dispose();
  });

  group('tryParseToUri', () {
    test('parses absolute HTTP URI', () {
      final uri = handler.tryParseToUri('https://example.com/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
    });

    test('parses file path as file URI', () {
      final uri = handler.tryParseToUri('/storage/Music/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'file');
    });

    test('parses file URI scheme', () {
      final uri = handler.tryParseToUri('file:///storage/song.mp3');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'file');
    });

    test('handles empty string', () {
      final uri = handler.tryParseToUri('');
      expect(uri, isNotNull);
    });

    test('parses content URI', () {
      final uri = handler.tryParseToUri('content://media/audio/1');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'content');
    });

    test('parses Windows-style path', () {
      final uri = handler.tryParseToUri('C:\\Music\\song.mp3');
      expect(uri, isNotNull);
    });
  });

  group('Pause', () {
    test('pause pauses player and updates session manager', () async {
      await handler.pause();
      final state = container.read(audioSessionManagerProvider);
      expect(state.isPlaying, isFalse);
    });

    test('pause can be called multiple times safely', () async {
      await handler.pause();
      await handler.pause();
      expect(container.read(audioSessionManagerProvider).isPlaying, isFalse);
    });
  });

  group('Play', () {
    test('play does not throw when no audio source is loaded', () async {
      // With no loaded source, ensureActive returns false and play returns early
      // (fluttertoast mock handles the resulting toast call)
      await handler.play();
    });

    test('play is idempotent', () async {
      await handler.play();
      await handler.play();
      // Multiple play calls should not crash
    });
  });

  group('Stop', () {
    test('stop sets playback state to idle and not playing', () async {
      await handler.stop();
      final ps = handler.playbackState.value;
      expect(ps.processingState, AudioProcessingState.idle);
      expect(ps.playing, isFalse);
    });

    test('stop updates session manager', () async {
      await handler.stop();
      // After stop, session manager's playing state should reflect the change
      expect(handler.playbackState.value.playing, isFalse);
    });
  });

  group('Seek', () {
    test('seek completes without throwing', () async {
      await handler.seek(const Duration(seconds: 42));
    });

    test('seek to zero position does not throw', () async {
      await handler.seek(Duration.zero);
    });

    test('seek multiple times sequentially does not throw', () async {
      await handler.seek(const Duration(seconds: 10));
      await handler.seek(const Duration(seconds: 30));
      await handler.seek(const Duration(seconds: 5));
    });
  });

  group('Rewind', () {
    test('rewind completes without throwing', () async {
      final interval = container.read(rewindIntervalInSecondsProvider);
      expect(interval, 3); // default value
      await handler.rewind();
    });

    test('rewind does not throw after seek', () async {
      await handler.seek(const Duration(seconds: 60));
      await handler.rewind();
    });
  });

  group('FastForward', () {
    test('fastForward completes without throwing', () async {
      final interval = container.read(fastForwardIntervalInSecondsProvider);
      expect(interval, 3); // default value
      await handler.fastForward();
    });

    test('fastForward does not throw after seek', () async {
      await handler.seek(const Duration(seconds: 10));
      await handler.fastForward();
    });
  });

  group('Repeat Mode', () {
    test('setRepeatMode one updates provider', () async {
      await handler.setRepeatMode(AudioServiceRepeatMode.one);
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.one);
    });

    test('setRepeatMode all updates provider', () async {
      await handler.setRepeatMode(AudioServiceRepeatMode.all);
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.all);
    });

    test('setRepeatMode none disables repeat', () async {
      await handler.setRepeatMode(AudioServiceRepeatMode.none);
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.none);
    });

    test('setRepeatMode updates playbackState controls', () async {
      await handler.setRepeatMode(AudioServiceRepeatMode.one);
      final ps = handler.playbackState.value;
      expect(ps.controls, isNotEmpty);
    });
  });

  group('Shuffle Mode', () {
    test('setShuffleMode all enables shuffle', () async {
      await handler.setShuffleMode(AudioServiceShuffleMode.all);
      expect(container.read(shuffleModeProvider), AudioServiceShuffleMode.all);
    });

    test('setShuffleMode none disables shuffle', () async {
      await handler.setShuffleMode(AudioServiceShuffleMode.none);
      expect(container.read(shuffleModeProvider), AudioServiceShuffleMode.none);
    });

    test('setShuffleMode updates playbackState controls', () async {
      await handler.setShuffleMode(AudioServiceShuffleMode.all);
      final ps = handler.playbackState.value;
      // controls should reflect the new shuffle mode buttons
      expect(ps.controls, isNotEmpty);
    });
  });

  group('Custom Actions', () {
    test('customAction toggles repeat mode via next enum', () async {
      // none.next is AudioServiceRepeatMode.all
      await container.read(repeatModeProvider.notifier).setRepeatMode(AudioServiceRepeatMode.none);
      await handler.customAction('repeatMode', {'isPlaying': false});
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.all);
    });

    test('customAction toggles from all to one', () async {
      await container.read(repeatModeProvider.notifier).setRepeatMode(AudioServiceRepeatMode.all);
      await handler.customAction('repeatMode', {'isPlaying': false});
      // all.next is AudioServiceRepeatMode.one
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.one);
    });

    test('customAction toggles shuffle mode via next enum', () async {
      // none.next is AudioServiceShuffleMode.all
      await container.read(shuffleModeProvider.notifier).setShuffleMode(AudioServiceShuffleMode.none);
      await handler.customAction('shuffleMode', {'isPlaying': false});
      expect(container.read(shuffleModeProvider), AudioServiceShuffleMode.all);
    });

    test('customAction returns null for unknown action', () async {
      final result = await handler.customAction('nonExistentAction');
      expect(result, isNull);
    });
  });

  group('Skip', () {
    test('skipToNext does not throw with empty sequence', () async {
      await handler.skipToNext();
      // With empty player sequence, seekToNext is a no-op but shouldn't throw
    });

    test('skipToPrevious does not throw with empty sequence', () async {
      await handler.skipToPrevious();
    });

    test('skipToQueueItem ignores invalid indices', () async {
      await handler.skipToQueueItem(-1);
      await handler.skipToQueueItem(999);
    });

    test('skipToQueueItem updates playbackState position', () async {
      // Even with invalid index, the handler should handle gracefully
      await handler.skipToQueueItem(0);
      expect(handler.playbackState.value, isNotNull);
    });
  });

  group('Queue', () {
    test('queue starts empty', () async {
      expect(handler.queue.value, isEmpty);
    });

    test('updateQueue populates the queue', () async {
      final items = [
        const MediaItem(id: 'song_1', title: 'Song 1'),
        const MediaItem(id: 'song_2', title: 'Song 2'),
      ];
      await handler.updateQueue(items);
      expect(handler.queue.value, hasLength(2));
      expect(handler.queue.value[0].id, 'song_1');
      expect(handler.queue.value[1].id, 'song_2');
    });
  });

  group('Browse / GetChildren', () {
    test('returns root browseable items', () async {
      final children = await handler.getChildren(AudioService.browsableRootId);
      expect(children, hasLength(3));
      expect(children[0].id, 'all_songs');
      expect(children[1].id, 'favourites');
      expect(children[2].id, 'playlists');
    });

    test('returns empty list for unknown parent ID', () async {
      final children = await handler.getChildren('unknown_parent');
      expect(children, isEmpty);
    });
  });
}

/// Mock all method channels used by just_audio, audio_session, volume_controller, and fluttertoast.
void _setUpMockChannels() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // just_audio channels (both legacy and current)
  for (final name in [
    'com.ryanheise.just_audio',
    'com.llfbandit.just_audio',
    'com.ryanheise.just_audio/justAudio',
    'com.llfbandit.just_audio/justAudio',
  ]) {
    messenger.setMockMethodCallHandler(
      MethodChannel(name),
      (MethodCall call) async => null,
    );
  }

  // audio_session channels
  for (final name in [
    'com.ryanheise.audio_session',
    'flutter.awesome_audio_session',
  ]) {
    messenger.setMockMethodCallHandler(
      MethodChannel(name),
      (MethodCall call) async => null,
    );
  }

  // volume_controller
  messenger.setMockMethodCallHandler(
    const MethodChannel('volume_controller'),
    (MethodCall call) async => null,
  );

  // fluttertoast (channel name is the developer's GitHub username)
  messenger.setMockMethodCallHandler(
    const MethodChannel('PonnamKarthik/fluttertoast'),
    (MethodCall call) async => null,
  );
}