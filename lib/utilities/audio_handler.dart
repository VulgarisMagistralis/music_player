import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:rxdart/rxdart.dart';

///TODO user settings
bool resumeOnConnection = true;
bool resumeOnDisconnect = false;
bool pauseOnBackground = false;
//possible?
bool pauseOnHidden = false;
bool pauseOnMuted = true;
// if first launch or corrupted last song save=> start from 1st song in Songs (or configurable)
bool resumeMusicOnLaunch = false;

class PlayerAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final List<UriAudioSource> currentQueue = [];
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;
  final Future<AudioSession> _session = AudioSession.instance;
  late StreamSubscription<void>? _noisySubscription;
  late StreamSubscription<double>? _volumeSubscription;
  late StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  late StreamSubscription<AudioDevicesChangedEvent>? _devicesChangedEventSubscription;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AudioProcessingState _mapProcessingState(ProcessingState processingState) => switch (processingState) {
    ProcessingState.idle => AudioProcessingState.idle,
    ProcessingState.ready => AudioProcessingState.ready,
    ProcessingState.loading => AudioProcessingState.loading,
    ProcessingState.buffering => AudioProcessingState.buffering,
    ProcessingState.completed => AudioProcessingState.completed,
  };

  Future<void> init() async {
    final session = await _session;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
    await _player.setAndroidAudioAttributes(const AndroidAudioAttributes(contentType: AndroidAudioContentType.music, usage: AndroidAudioUsage.media));
    _player.playerStateStream.listen((playerState) {
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
          // Which controls to show in Android's compact view.
          androidCompactActionIndices: const [1, 2, 3],
          playing: playerState.playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          processingState: _mapProcessingState(playerState.processingState),
        ),
      );
    });
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _player.sequence.length) mediaItem.add(_player.sequence[index].tag as MediaItem);
    });
    _interruptionSubscription = session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
            await pause();
          case AudioInterruptionType.duck:
            await pause();
          case AudioInterruptionType.unknown:
        }
      } else {
        await play();
      }
    });
    _noisySubscription = session.becomingNoisyEventStream.listen((_) async => resumeOnDisconnect ? null : await pause());
    _volumeSubscription = _player.volumeStream.listen((volumeValue) async => volumeValue < 0 && pauseOnMuted ? await pause() : null);
    _devicesChangedEventSubscription = session.devicesChangedEventStream.listen((event) async {
      if (event.devicesAdded.isNotEmpty) {
        await ensureActive();
        if (resumeOnConnection) await play();
      } else {
        await pause();
      }
    });
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
    await _player.setAudioSources(
      queueItems.map((MediaItem item) {
        return AudioSource.uri(Uri.file(songList[i++].path), tag: item);
      }).toList(),
      initialIndex: index,
    );
    await updateQueue(queueItems);

    // Start playback at the selected song
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

  Future<bool> ensureActive() async => _player.audioSource != null ? await (await _session).setActive(true) : false;

  @override
  Future<void> play() async {
    await ensureActive() ? await _player.play() : ToastManager().showErrorToast('Failed to open file');
  }

  Future<void> playSongAtIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  Future<void> clearAudioSources() async {
    await _player.clearAudioSources();
  }

  Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    _player.positionStream,
    _player.bufferedPositionStream,
    _player.durationStream,
    (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero),
  );

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    // reflect modified version of app pages
    if (parentMediaId == AudioService.browsableRootId) {
      return [
        const MediaItem(id: 'queue', title: 'Now Playing Queue', playable: false, extras: {'browsable': true}),
        const MediaItem(id: 'playlists', title: 'Playlists', playable: false),
        const MediaItem(id: 'playlists1', title: 'Playlists1', playable: false),
      ];
    }
    if (parentMediaId == 'queue') return queue.value.map((item) => item.copyWith(playable: true)).toList();
    return [];
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

  Future<void> dispose() async {
    await clearAudioSources();
    await _player.dispose();
    await _noisySubscription?.cancel();
    await _interruptionSubscription?.cancel();
    await _volumeSubscription?.cancel();
    await _devicesChangedEventSubscription?.cancel();
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
