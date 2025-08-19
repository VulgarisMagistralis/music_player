import 'dart:io' show FileSystemEntity, File;
import 'dart:async' show StreamSubscription;
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart' show WidgetsBinding, WidgetsBindingObserver, AppLifecycleState;
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/song.dart';
import 'package:rxdart/rxdart.dart' show Rx;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/data/position.dart' show PositionData;

///TODO user settings
bool resumeOnConnection = true;
bool resumeOnDisconnect = false;
bool pauseOnBackground = false;
//possible?
bool pauseOnHidden = false;
bool pauseOnMuted = true;
// if first launch or corrupted last song save=> start from 1st song in Songs (or configurable)
bool resumeMusicOnLaunch = false;

class AudioSessionManager extends AsyncNotifier<AudioSessionState> with WidgetsBindingObserver {
  AudioSessionManager();
  late final AudioPlayer _player;
  final _session = AudioSession.instance;
  String get songName => state.value?.title ?? '';
  bool _wasPlayingBeforeInterruption = false;

  late Stream<PlayerState> _playerStateStream;
  late StreamSubscription<void>? _noisySubscription;
  late StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  late StreamSubscription<double>? _volumeSubscription;
  late StreamSubscription<AudioDevicesChangedEvent>? _devicesChangedEventSubscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('_____________' + state.name);
        break;
      case AppLifecycleState.inactive:
        print('_____________' + state.name);
        // Optionally pause or reduce audio focus
        if (pauseOnBackground) await pause();
        break;
      case AppLifecycleState.resumed:
        await ensureActive();
        print('_____________' + state.name);
        if (!_player.playing) await play();
        break;
      case AppLifecycleState.detached:
        print('_____________' + state.name);
        if (pauseOnBackground) await pause();
        break;
      case AppLifecycleState.hidden:
        print('_____________' + state.name);
        if (pauseOnHidden) await pause();
        break;
    }
  }

  bool get hasPrevious => _player.hasPrevious;
  bool get hasNext => _player.hasNext;

  Future<void> seekToPrevious() async => await _player.seekToPrevious();
  Future<void> seekToNext() async {
    await _player.seekToNext();
  }

  Future<void> init() async {
    final session = await _session;
    await session.setActive(true);
    await session.configure(const AudioSessionConfiguration(
        androidWillPauseWhenDucked: true,
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidAudioAttributes: AndroidAudioAttributes(contentType: AndroidAudioContentType.music, flags: AndroidAudioFlags.none)));
    _interruptionSubscription = session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        if (_player.playing) _wasPlayingBeforeInterruption = true;
        await pause();
      } else {
        if (_wasPlayingBeforeInterruption) {
          await play();
          _wasPlayingBeforeInterruption = false;
        }
      }
    });
    _player.currentIndexStream.listen((index) async {
      if (index == null) return;

      final sequence = _player.sequence;
      if (index < sequence.length) {
        final tag = sequence[index].tag as MediaItem;
        final file = File(tag.id);
        state = AsyncValue.data(
          state.value!.copyWith(
            title: tag.title,
            file: file,
            isReady: await file.exists(),
          ),
        );
      }
    });
    _playerStateStream = _player.playerStateStream;
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

  Future<void> setPlaylist(List<FileSystemEntity> files, List<String> titles, {int index = 0}) async {
    final sources = List<AudioSource>.generate(
      files.length,
      (index) => AudioSource.uri(
        Uri.file(files[index].path),
        tag: MediaItem(
          id: files[index].path, // store the path so we can rebuild state later
          title: titles[index],
        ),
      ),
    );
    state = AsyncValue.data(AudioSessionState(title: titles.isNotEmpty ? titles[0] : '', file: files.isNotEmpty ? files[0] : null, isReady: files.isNotEmpty ? await files[0].exists() : false));
    Uint8List? pictureByteList;
    FileSystemEntity file = files[index];

    AudioMetadata metaData = readMetadata(File(file.path), getImage: true);
    List<Picture> pictures = metaData.pictures;
    print('________________${metaData.title}');
    print('________________${metaData.artist}');
    print('________________${metaData.album}');
    if (pictures.isNotEmpty) {
      print('________________' + pictures.toString());
      pictureByteList = pictures.first.bytes;
    }

    state = AsyncValue.data(state.value!.copyWith(title: titles[index], file: file, isReady: await file.exists(), albumArt: pictureByteList));
    await _player.setAudioSources(sources, initialIndex: index);
    ToastManager().showToast((await _player.nextIndex).toString());
    await play();
  }

  bool isReady() => _player.audioSource != null;
  Stream<PlayerState> get playerStateStream => _playerStateStream;

  Future<bool> ensureActive() async {
    final session = await _session;
    return isReady() ? await session.setActive(true) : false;
  }

  Future<void> setAudioSource({required String title, required FileSystemEntity file}) async {
    Uint8List? pictureByteList;
    AudioMetadata metaData = readMetadata(File(file.path), getImage: true);
    List<Picture> pictures = metaData.pictures;
    print('________________${metaData.title}');
    print('________________${metaData.artist}');
    print('________________${metaData.album}');
    if (pictures.isNotEmpty) {
      print('________________' + pictures.toString());
      pictureByteList = pictures.first.bytes;
    }
    state = AsyncValue.data(state.value!.copyWith(title: title, file: file, isReady: await file.exists(), albumArt: pictureByteList));
    await _player.setAudioSource(AudioSource.file(file.path, tag: MediaItem(title: title, id: title)));
  }

  Future<void> playSongAtIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  Future<void> play() async {
    ///error?
    await ensureActive() ? await _player.play() : ToastManager().showToast('Failed to open file');
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    final session = await _session;
    await session.setActive(false);
  }

  Future<void> clearAudioSources() async {
    await _player.clearAudioSources();
  }

  Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player.positionStream, _player.bufferedPositionStream, _player.durationStream, (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await clearAudioSources();
    WidgetsBinding.instance.removeObserver(this);
    await _player.dispose();
    await _noisySubscription?.cancel();
    await _interruptionSubscription?.cancel();
    await _volumeSubscription?.cancel();
    await _devicesChangedEventSubscription?.cancel();
  }

  @override
  Future<AudioSessionState> build() async {
    _player = AudioPlayer();
    await init();
    return AudioSessionState.initial();
  }
}
