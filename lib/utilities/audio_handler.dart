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
        _container.read(audioSessionManagerProvider.notifier).updateState(isPlaying: playerState.playing, isReady: playerState.processingState != ProcessingState.idle);
      }),
    );
    _subscriptionList.add(
      _player.positionStream.listen((Duration position) {
        playbackState.add(playbackState.value.copyWith(updatePosition: position, bufferedPosition: _player.bufferedPosition));
      }),
    );
  }

  void _listenToInterruptions() {
    _session.then((session) {
      session.interruptionEventStream.listen((AudioInterruptionEvent event) async {
        if (event.begin) {
          if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) {
            _pausedForInterruption = true;
            await _handlePlayPause(shouldPause: true);
          }
        } else if (_pausedForInterruption) {
          _pausedForInterruption = false;
          await _handlePlayPause(shouldPause: false);
        }
      });
    });
  }

  void _listenToDevicesChanged() async => _subscriptionList.add(
    (await _session).devicesChangedEventStream.listen((AudioDevicesChangedEvent event) async {
      if (event.devicesAdded.isNotEmpty) {
        await restoreSession();
        await ensureActive();
        if (_container.read(playOnConnectProvider)) {
          await _handlePlayPause(shouldPause: false);
        }
      }
    }),
  );

  void _listenToNoisyEvents() async =>
      _subscriptionList.add((await _session).becomingNoisyEventStream.listen((_) async => !_container.read(resumeAfterDisconnectProvider) ? await _handlePlayPause(shouldPause: true) : null));

  void _listenToVolume() => _subscriptionList.add(
    _player.volumeStream.listen((double v) async {
      v <= 0 && _container.read(pauseWhenMutedProvider) ? await _handlePlayPause(shouldPause: true) : null;
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
    try {
      final AudioSessionState? savedAudioSession = _container.read(audioSessionManagerProvider);
      if (savedAudioSession == null || savedAudioSession.songId == null) return;

      final String playlistId = savedAudioSession.playlistId;
      final List<Song> songs = await _getSongsForPlaylist(playlistId);

      // Find the actual index of the saved song in the current playlist
      // rather than trusting the saved index (which may be stale if songs were added/removed)
      final int songIndex = songs.indexWhere((s) => s.id == savedAudioSession.songId);
      final int startIndex = songIndex >= 0 ? songIndex : (songs.isNotEmpty ? 0 : -1);

      if (songs.isNotEmpty && startIndex >= 0) {
        await setPlaylist(playlistId, songs, index: startIndex);
      } else {
        // Fallback: play the saved song directly if playlist is empty or unavailable
        final song = await getSong(id: savedAudioSession.songId!);
        if (song == null) return;
        final newMediaItem = await SongMediaItemFactory.fromSong(song);
        await _player.setAudioSource(AudioSource.uri(Uri.file(song.path), tag: newMediaItem));
        mediaItem.add(newMediaItem);
      }
    } catch (e) {
      ToastManager().showErrorToast('Error restoring previous session: $e');
    }
  }

  Future<List<Song>> _getSongsForPlaylist(String playlistId) async {
    switch (playlistId) {
      case 'songs':
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
      try {
        await subscription.cancel();
      } catch (_) {}
    }
    _subscriptionList.clear();
    await clearAudioSources();
    await _player.dispose();
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
      await _handlePlayPause(shouldPause: false);
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
    for (int i = 0; i < songList.length; i++) {
      final Song song = songList[i];
      final file = File(song.path);
      if (file.existsSync()) {
        final MediaItem newMediaItem = await SongMediaItemFactory.fromSong(song);
        validSources.add(AudioSource.uri(Uri.file(song.path), tag: newMediaItem));
        queueItems.add(newMediaItem);
      } else {
        ToastManager().showErrorToast('Skipped ${song.title}\nFile not found');
      }
    }
    if (validSources.isEmpty) return;
    await _container.read(audioSessionManagerProvider.notifier).updateState(playlistId: playlistId);
    final safeIndex = index < validSources.length ? index : 0;
    await _player.setAudioSources(validSources, initialIndex: safeIndex);
    await updateQueue(queueItems);
    await _handlePlayPause(shouldPause: false);
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

  /// Centralized play/pause handler to avoid duplicate error toasts
  Future<void> _handlePlayPause({required bool shouldPause}) async {
    if (shouldPause) {
      await pause();
    } else {
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
  }

  @override
  Future<void> play() async {
    await _handlePlayPause(shouldPause: false);
  }

  Future<void> playSongAtIndex(int index) async {
    if (index < 0 || index >= _player.sequence.length) return;
    await _player.seek(Duration.zero, index: index);
    await _handlePlayPause(shouldPause: false);
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
    final wasPlaying = playbackState.value.playing;
    await _player.seekToNext();
    if (wasPlaying) {
      await _player.play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final wasPlaying = playbackState.value.playing;
    await _player.seekToPrevious();
    if (wasPlaying) {
      await _player.play();
    }
  }

  @override
  Future<void> rewind() async {
    final int newRewindValue = _container.read(rewindIntervalInSecondsProvider);
    final currentPosition = _player.position;
    final newPosition = currentPosition - Duration(seconds: newRewindValue);
    await seek(newPosition);
  }

  @override
  Future<void> fastForward() async {
    final int newFastForwardValue = _container.read(fastForwardIntervalInSecondsProvider);
    final currentPosition = _player.position;
    final newPosition = currentPosition + Duration(seconds: newFastForwardValue);
    await seek(newPosition);
  }

  @override
  Future<void> seek(Duration position) async {
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
    await _player.seek(position);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final Uri? sourceUri = tryParseToUri(mediaItem.id);
    if (sourceUri == null) return;
    final source = AudioSource.uri(sourceUri, tag: mediaItem);
    if (_player.sequence is AudioSource) {
      await _player.addAudioSource(source);
    }
    queue.add([...queue.value, mediaItem]);
  }

  /// Tries to parse a media item ID as a URI.
  /// Handles both file paths (when mediaItem.id is a file path)
  /// and regular media IDs (when mediaItem.id is already a valid URI string).
  Uri? tryParseToUri(String id) {
    // First, try parsing as a direct URI
    try {
      final uri = Uri.parse(id);
      if (uri.isAbsolute) return uri;
    } catch (_) {}
    // If that fails, try as a file path
    try {
      return Uri.file(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Accept the repeat mode from the caller instead of cycling
    final LoopMode loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.all => LoopMode.all,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.group => LoopMode.all,
    };
    await _player.setLoopMode(loopMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // Use the shuffle mode from the caller instead of ignoring it
    final bool enabled = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }
}
