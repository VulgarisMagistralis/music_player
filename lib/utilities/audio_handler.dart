import 'dart:io';
import 'dart:async';
import 'package:music_player/utilities/song_to_media.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/src/rust/api/data/song.dart';
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

  /// _______________ Life Cycle _______________
  Future<void> init(ProviderContainer provider) async {
    _container = provider;
    await _configureAudioSession();
    await _configurePlayerAttributes();
    _listenToPlayerState();
    _listenToCurrentIndex(provider);
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

  void _listenToVolume(ProviderContainer provider) => _subscriptionList.add(
    _player.volumeStream.listen((double v) async {
      v <= 0 && provider.read(pauseWhenMutedProvider) ? await pause() : null;
    }),
  );

  void _listenToCurrentIndex(ProviderContainer provider) => _subscriptionList.add(
    _player.currentIndexStream.listen((index) async {
      if (index == null || index >= _player.sequence.length) return;
      final MediaItem newMediaItem = _player.sequence[index].tag;
      provider.read(audioSessionManagerProvider.notifier).updateFromMediaItem(newMediaItem, index);
      mediaItem.add(newMediaItem);
    }),
  );

  Future<void> restoreSession(ProviderContainer ref) async {
    final AudioSessionState? savedAudioSession = ref.read(audioSessionManagerProvider);
    if (savedAudioSession == null || savedAudioSession.songId == null) return;
    final song = await getSong(id: savedAudioSession.songId!);
    if (song == null) return;
    final newMediaItem = await SongMediaItemFactory.fromSong(song);
    await _player.setAudioSource(AudioSource.uri(Uri.file(song.path), tag: newMediaItem));
    mediaItem.add(newMediaItem);
  }

  Future<void> dispose() async {
    await clearAudioSources();
    await _player.dispose();
    for (final StreamSubscription subscription in _subscriptionList) {
      await subscription.cancel();
    }
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
      await ensureActive() ? await _player.play() : ToastManager().showErrorToast('Failed to open file');
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
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.idle));
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
  Future<void> addQueueItem(MediaItem mediaItem) async => queue.add([...queue.value, mediaItem]);
}
