import 'dart:io';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/utilities/song_to_media.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/src/rust/api/song_collection.dart';
import 'package:music_player/utilities/audio_session_manager.dart';

class PlayerAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late ProviderContainer _container;
  final List<UriAudioSource> currentQueue = [];
  final List<StreamSubscription> _subscriptionList = [];
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;
  final Future<AudioSession> _session = AudioSession.instance;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  bool _pausedForInterruption = false;

  /// _______________ Life Cycle _______________
  Future<void> init(ProviderContainer provider) async {
    _container = provider;
    await _configureAudioSession();
    await _configurePlayerAttributes();
    _listenToPlayerState();
    _listenToCurrentIndex();
    _listenToInterruptions();
    _listenToNoisyEvents();
    _listenToVolume();
    _listenToDevicesChanged();
  }

  Future<void> _configureAudioSession() async {
    final AudioSession session = await _session;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
  }

  void _listenToPlayerState() {
    const systemActions = {
      MediaAction.seek,
      MediaAction.pause,
      MediaAction.setRepeatMode,
      MediaAction.setShuffleMode,
      MediaAction.rewind,
      MediaAction.fastForward,
      MediaAction.play,
      MediaAction.seekForward,
      MediaAction.seekBackward,
    };
    _subscriptionList.add(
      _player.playerStateStream.listen((PlayerState playerState) {
        final bool isShuffled = _player.shuffleModeEnabled;
        final bool isRepeatOne = _player.loopMode == LoopMode.one;
        final bool isRepeatAll = _player.loopMode == LoopMode.all;

        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.rewind,
              MediaControl.skipToPrevious,
              playerState.playing ? MediaControl.pause : MediaControl.play,
              MediaControl.skipToNext,
              MediaControl.fastForward,
              MediaControl(androidIcon: isShuffled ? 'drawable/ic_shuffle_active' : 'drawable/ic_shuffle', label: isShuffled ? 'Shuffle on' : 'Shuffle off', action: MediaAction.setShuffleMode),
              MediaControl(
                androidIcon: isRepeatOne
                    ? 'drawable/ic_repeat_one_active'
                    : isRepeatAll
                    ? 'drawable/ic_repeat_active'
                    : 'drawable/ic_repeat',
                label: isRepeatOne
                    ? 'Repeat one'
                    : isRepeatAll
                    ? 'Repeat all'
                    : 'Repeat off',
                action: MediaAction.setRepeatMode,
              ),
            ],
            systemActions: systemActions,
            playing: playerState.playing,
            shuffleMode: isShuffled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
            repeatMode: switch (_player.loopMode) {
              LoopMode.off => AudioServiceRepeatMode.none,
              LoopMode.one => AudioServiceRepeatMode.one,
              LoopMode.all => AudioServiceRepeatMode.all,
            },
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
    _subscriptionList.add(
      _player.positionStream.listen((Duration position) {
        playbackState.add(playbackState.value.copyWith(updatePosition: position, bufferedPosition: _player.bufferedPosition));
      }),
    );
  }

  void _listenToInterruptions() async => _subscriptionList.add(
    (await _session).interruptionEventStream.listen((AudioInterruptionEvent event) async {
      if (event.begin) {
        if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) {
          _pausedForInterruption = true;
          await pause();
        }
      } else if (_pausedForInterruption) {
        _pausedForInterruption = false;
        await play();
      }
    }),
  );

  void _listenToDevicesChanged() async => _subscriptionList.add(
    (await _session).devicesChangedEventStream.listen((AudioDevicesChangedEvent event) async {
      if (event.devicesAdded.isNotEmpty) {
        await restoreSession();
        await ensureActive();
        playbackState.add(playbackState.value.copyWith(playing: false, processingState: AudioProcessingState.ready));
        if (_container.read(playOnConnectProvider)) {
          await play();
        }
      }
    }),
  );

  void _listenToNoisyEvents() async => _subscriptionList.add((await _session).becomingNoisyEventStream.listen((_) async => !_container.read(resumeAfterDisconnectProvider) ? await pause() : null));

  void _listenToVolume() => _subscriptionList.add(
    _player.volumeStream.listen((double v) async {
      v <= 0 && _container.read(pauseWhenMutedProvider) ? await pause() : null;
    }),
  );

  void _listenToCurrentIndex() => _subscriptionList.add(
    _player.currentIndexStream.listen((index) async {
      if (index == null || index >= _player.sequence.length) return;
      final MediaItem newMediaItem = _player.sequence[index].tag;
      _container.read(audioSessionManagerProvider.notifier).updateFromMediaItem(newMediaItem, index);
      mediaItem.add(newMediaItem);
    }),
  );

  Future<void> restoreSession() async {
    final AudioSessionState? savedAudioSession = _container.read(audioSessionManagerProvider);
    if (savedAudioSession == null || savedAudioSession.songId == null) return;
    if (_player.audioSource != null && _player.sequence.isNotEmpty) return;
    final song = await getSong(id: savedAudioSession.songId!);
    if (song == null) return;
    final String playlistId = savedAudioSession.playlistId;
    final List<Song> songs = await _getSongsForPlaylist(playlistId);
    if (songs.isNotEmpty) {
      final int startIndex = savedAudioSession.songIndexInPlaylist;
      await setPlaylist(playlistId, songs, index: startIndex.clamp(0, songs.length - 1));
      return;
    }
    final newMediaItem = await SongMediaItemFactory.fromSong(song);
    await _player.setAudioSource(AudioSource.uri(Uri.file(song.path), tag: newMediaItem));
    mediaItem.add(newMediaItem);
  }

  Future<List<Song>> _getSongsForPlaylist(String playlistId) async {
    switch (playlistId) {
      case 'aa_browse':
        return await getAllSongsFromCollection();
      case 'favourites':
        final playlist = await _container.read(getFavouritesPlaylistProvider.future);
        return await _container.read(getPlaylistSongsProvider(playlist: playlist).future);
      default:
        if (playlistId.startsWith('playlist_')) {
          final id = BigInt.tryParse(playlistId.replaceFirst('playlist_', ''));
          if (id != null) {
            final playlists = await _container.read(playlistCollectionProvider.future);
            final playlist = playlists.firstWhere((p) => p.id == id);
            if (playlist.songIdList.isEmpty) return [];
            return await _container.read(getPlaylistSongsProvider(playlist: playlist).future);
          }
        }
        return [];
    }
  }

  Future<void> dispose() async {
    for (final StreamSubscription subscription in _subscriptionList) {
      await subscription.cancel();
    }
    await clearAudioSources();
    await _player.dispose();
    _subscriptionList.clear();
    final session = await _session;
    await session.setActive(false);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _player.sequence.length) return;
    await _player.seek(Duration.zero, index: index);
    mediaItem.add(_player.sequence[index].tag as MediaItem);
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    final index = queue.value.indexWhere((item) => item.id == mediaId);
    if (index >= 0) {
      await _player.seek(Duration.zero, index: index);
      await play();
      return;
    }
    final songs = await getAllSongsFromCollection();
    final songIndex = songs.indexWhere((s) => Uri.file(s.path).toString() == mediaId);
    if (songIndex >= 0) {
      await setPlaylist('aa_browse', songs, index: songIndex);
    }
  }

  Future<void> setPlaylist(String playlistId, List<Song> songList, {int index = 0}) async {
    final List<AudioSource> validSources = [];
    final List<MediaItem> queueItems = [];
    final List<AudioSessionState> sessionStates = [];
    for (int i = 0; i < songList.length; i++) {
      final Song song = songList[i];
      final file = File(song.path);
      if (file.existsSync()) {
        final MediaItem newMediaItem = await SongMediaItemFactory.fromSong(song);
        validSources.add(AudioSource.uri(Uri.file(song.path), tag: newMediaItem));
        queueItems.add(newMediaItem);
        sessionStates.add(AudioSessionState(playlistId: playlistId, file: file, title: song.title, songIndexInPlaylist: i, asMediaItem: newMediaItem));
        await _container.read(audioSessionManagerProvider.notifier).updateState(playlistId: playlistId);
      } else {
        ToastManager().showErrorToast('Skipped ${song.title}\nFile not found');
      }
    }
    if (validSources.isEmpty) return;
    final safeIndex = index < validSources.length ? index : 0;
    await _player.setAudioSources(validSources, initialIndex: safeIndex);
    await updateQueue(queueItems);
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

  Future<void> _configurePlayerAttributes() async => await _player.setAndroidAudioAttributes(const AndroidAudioAttributes(contentType: AndroidAudioContentType.music, usage: AndroidAudioUsage.media));

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return [
          const MediaItem(id: 'all_songs', title: 'All Songs', playable: false, extras: {'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2}),
          const MediaItem(id: 'favourites', title: 'Favourites', playable: false, extras: {'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2}),
          const MediaItem(id: 'playlists', title: 'Playlists', playable: false, extras: {'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2}),
        ];

      case 'all_songs':
        final songs = await _container.read(allSongsProvider.future);
        return await SongMediaItemFactory.fromSongs(songs);

      case 'favourites':
        final playlist = await _container.read(getFavouritesPlaylistProvider.future);
        final songs = await _container.read(getPlaylistSongsProvider(playlist: playlist).future);
        return await SongMediaItemFactory.fromSongs(songs);

      case 'playlists':
        final playlists = await _container.read(playlistCollectionProvider.future);
        return playlists.map((p) => MediaItem(id: 'playlist_${p.id}', title: p.name, playable: false, extras: {'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2})).toList();

      default:
        if (parentMediaId.startsWith('playlist_')) {
          final playlistId = BigInt.parse(parentMediaId.replaceFirst('playlist_', ''));
          final playlists = await _container.read(playlistCollectionProvider.future);
          final playlist = playlists.firstWhere((p) => p.id == playlistId);
          final songs = await _container.read(getPlaylistSongsProvider(playlist: playlist).future);
          return await SongMediaItemFactory.fromSongs(songs);
        }
        return [];
    }
  }

  @override
  Future<void> play() async {
    try {
      final active = await ensureActive();
      if (!active) {
        ToastManager().showErrorToast('Could not activate audio session');
        return;
      }
      await _player.play();
      await _container.read(audioSessionManagerProvider.notifier).updateState(isPlaying: true);
    } catch (e) {
      ToastManager().showErrorToast('Error playing audio: $e');
    }
  }

  Future<void> playSongAtIndex(int index) async {
    if (index < 0 || index >= _player.sequence.length) return;
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await _container.read(audioSessionManagerProvider.notifier).updateState(isPlaying: false);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.idle, playing: false));
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
  Future<void> seek(Duration position) async {
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
    await _player.seek(position);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final source = AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem);
    await _player.addAudioSource(source);
    queue.add([...queue.value, mediaItem]);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Cycle through repeat modes: none -> all -> one -> none
    final LoopMode nextLoopMode = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(nextLoopMode);
    playbackState.add(
      playbackState.value.copyWith(
        repeatMode: switch (nextLoopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
      ),
    );
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = !_player.shuffleModeEnabled;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(shuffleMode: enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none));
  }
}
