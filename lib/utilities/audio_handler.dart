import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

class PlayerAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final List<UriAudioSource> currentQueue = [];
  final List<StreamSubscription> _subscriptionList = [];
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;
  final Future<AudioSession> _session = AudioSession.instance;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// _______________ Life Cycle _______________
  Future<void> init(ProviderContainer provider) async {
    await _configureAudioSession();
    await _configurePlayerAttributes();
    _listenToPlayerState();
    _listenToCurrentIndex();
    _listenToInterruptions();
    _listenToNoisyEvents(provider);
    _listenToVolume(provider);
    _listenToDevicesChanged(provider);
  }

  Future<void> _configureAudioSession() async {
    final AudioSession session = await _session;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
  }

  void _listenToPlayerState() => _subscriptionList.add(
    _player.playerStateStream.listen((PlayerState playerState) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [MediaControl.rewind, MediaControl.skipToPrevious, playerState.playing ? MediaControl.pause : MediaControl.play, MediaControl.skipToNext, MediaControl.fastForward],
          systemActions: const {
            MediaAction.seek,
            MediaAction.pause,
            MediaAction.setRepeatMode,
            MediaAction.setShuffleMode,
            MediaAction.rewind,
            MediaAction.fastForward,
            MediaAction.play,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [1, 2, 3],
          playing: playerState.playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          processingState: switch (playerState.processingState) {
            ProcessingState.idle => AudioProcessingState.idle,
            ProcessingState.ready => AudioProcessingState.ready,
            ProcessingState.loading => AudioProcessingState.loading,
            ProcessingState.buffering => AudioProcessingState.buffering,
            ProcessingState.completed => AudioProcessingState.completed,
          },
        ),
      );
    }),
  );

  void _listenToInterruptions() async => _subscriptionList.add(
    (await _session).interruptionEventStream.listen((AudioInterruptionEvent event) async {
      if (event.begin) {
        if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) {
          await pause();
        }
      }
      if (!event.begin && event.type == AudioInterruptionType.unknown) {
        await play();
      }
    }),
  );

  /// test
  void _listenToDevicesChanged(ProviderContainer provider) async => _subscriptionList.add(
    (await _session).devicesChangedEventStream.listen((AudioDevicesChangedEvent event) async {
      if (event.devicesAdded.isNotEmpty) {
        if (provider.read(playOnConnectProvider)) {
          await ensureActive();
          await play();
        }
      }
    }),
  );

  void _listenToNoisyEvents(ProviderContainer provider) async => _subscriptionList.add((await _session).becomingNoisyEventStream.listen((_) async => !provider.read(resumeAfterDisconnectProvider) ? await pause() : null));
  // todo volume_controller 3.4.1
  void _listenToVolume(ProviderContainer provider) => _subscriptionList.add(
    _player.volumeStream.listen((double v) async {
      v <= 0 && provider.read(pauseWhenMutedProvider) ? await pause() : null;
    }),
  );
  void _listenToCurrentIndex() => _subscriptionList.add(_player.currentIndexStream.listen((index) => index != null && index < _player.sequence.length ? mediaItem.add(_player.sequence[index].tag as MediaItem) : null));

  Future<void> restoreSession(ProviderContainer ref) async {
    final AudioSessionState? savedAudioSession = ref.read(audioSessionManagerProvider);
    if (savedAudioSession == null) return;
    final List<Song> sortedSongList = await ref.read(sortedSongListProvider.future);
    final index = sortedSongList.indexWhere((s) => s.id == savedAudioSession.songId);
    await setPlaylist(savedAudioSession.playlistId, sortedSongList, index: index);
    if (savedAudioSession.isPlaying) {
      // await play();
    }
  }

  Future<void> dispose() async {
    await clearAudioSources();
    await _player.dispose();
    for (final StreamSubscription subscription in _subscriptionList) {
      await subscription.cancel();
    }
    _subscriptionList.clear();
  }

  /// When android auto tap on song
  /// need to match that action to player action
  @override
  Future<void> skipToQueueItem(int index) async {
    if (_player.sequence.isEmpty || index < 0 || index >= _player.sequence.length) return;
    await _player.seek(Duration.zero, index: index);
    // await play();
    // Make sure mediaItem stream updates UI
    mediaItem.add(_player.sequence[index].tag as MediaItem);
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    final index = queue.value.indexWhere((item) => item.id == mediaId);
    if (index >= 0) {
      await _player.seek(Duration.zero, index: index);
      await play();
    }
  }

  Future<void> setPlaylist(String playlistId, List<Song> songList, {int index = 0}) async {
    final List<AudioSessionState> sources = [];
    for (Song song in songList) {
      try {
        sources.add(
          const AudioSessionState().copyWith(
            playlistId: playlistId,
            file: File(song.path),
            title: song.title,
            songIndexInPlaylist: songList.indexOf(song),
            asMediaItem: MediaItem(id: song.id.toString(), title: song.title),
          ),
        );
      } catch (e) {
        ToastManager().showErrorToast('Skipped ${song.title}\nCannot find the file');
      }
    }

    // Update AudioService queue
    final List<MediaItem> queueItems = sources.map((s) => s.asMediaItem!).toList();
    // Set audio sources for Just Audio
    ///!XX
    int i = 0;
    await _player.setAudioSources(queueItems.map((MediaItem item) => AudioSource.uri(Uri.file(songList[i++].path), tag: item)).toList(), initialIndex: index);
    await updateQueue(queueItems);
    // Start playback at the selected song
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  Future<bool> ensureActive() async => _player.audioSource != null ? await (await _session).setActive(true) : false;

  Future<void> clearAudioSources() async => await _player.clearAudioSources();

  Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    _player.positionStream,
    _player.bufferedPositionStream,
    _player.durationStream,
    (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero),
  );

  /// _______________ Android Auto  _______________
  Future<void> _configurePlayerAttributes() async => await _player.setAndroidAudioAttributes(const AndroidAudioAttributes(contentType: AndroidAudioContentType.music, usage: AndroidAudioUsage.media));

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    if (parentMediaId == AudioService.browsableRootId) {
      return [
        const MediaItem(id: 'queue', title: 'Now Playing Queue', playable: false, extras: {'browsable': true, 'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1}),
        const MediaItem(id: 'playlists', title: 'Playlists', playable: false, extras: {'browsable': true, 'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1}),
      ];
    }
    if (parentMediaId == 'queue') {
      return queue.value.map((item) {
        return MediaItem(
          id: item.id.startsWith('file:') || item.id.startsWith('content:') ? item.id : Uri.file(item.id).toString(), // ensure stable URI string
          title: item.title,
          album: item.album,
          artist: item.artist,
          artUri: item.artUri ?? (item.extras?['artPath'] != null ? Uri.file(item.extras!['artPath']) : null),
          duration: item.duration,
          extras: item.extras,
        );
      }).toList();
    }
    return [];
  }

  /// _______________ Controls _______________
  @override
  Future<void> play() async {
    await ensureActive() ? await _player.play() : ToastManager().showErrorToast('Failed to open file');
  }

  Future<void> playSongAtIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await (await _session).setActive(false);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
    await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
    await _player.play();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final newQueue = [...queue.value, mediaItem];
    queue.add(newQueue);
    await _player.setAudioSources(newQueue.map((item) => AudioSource.uri(Uri.parse(item.id), tag: item)).toList(), initialIndex: 0);
  }
}
