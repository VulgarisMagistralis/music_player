import 'dart:io' show FileSystemEntity;
import 'dart:async' show StreamSubscription;
import 'package:flutter/material.dart' show WidgetsBinding, WidgetsBindingObserver, AppLifecycleState;
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

  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> seekToNext() => _player.seekToNext();
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
        await _player.pause();
      } else {
        if (_wasPlayingBeforeInterruption) {
          await _player.play();
          _wasPlayingBeforeInterruption = false;
        }
      }
    });
    _playerStateStream = _player.playerStateStream;
    _noisySubscription = session.becomingNoisyEventStream.listen((_) async => resumeOnDisconnect ? null : await _player.pause());
    _volumeSubscription = _player.volumeStream.listen((volumeValue) async => volumeValue < 0 && pauseOnMuted ? await _player.pause() : null);
    _devicesChangedEventSubscription = session.devicesChangedEventStream.listen((event) async => event.devicesAdded.isNotEmpty
        ? resumeOnConnection
            ? await play()
            : await pause()
        : await pause());
  }

  Future<void> setPlaylist(List<FileSystemEntity> files, List<String> titles) async {
    final sources = List<AudioSource>.generate(files.length, (index) => AudioSource.file(files[index].path, tag: MediaItem(id: index.toString(), title: titles[index])));
    state = AsyncValue.data(AudioSessionState(title: titles.isNotEmpty ? titles[0] : '', file: files.isNotEmpty ? files[0] : null, isReady: files.isNotEmpty ? await files[0].exists() : false));
    await _player.setAudioSources(sources, initialIndex: 0);
    await play();
  }

  bool isReady() => _player.audioSource != null;
  Stream<PlayerState> get playerStateStream => _playerStateStream;

  Future<bool> ensureActive() async {
    final session = await _session;
    return isReady() ? await session.setActive(true) : false;
  }

  Future<void> setAudioSource({required String title, required FileSystemEntity file}) async {
    await clearAudioSources();
    state = AsyncValue.data(state.value!.copyWith(title: title, file: file, isReady: await file.exists()));
    await _player.setAudioSource(AudioSource.file(file.path, tag: MediaItem(title: title, id: title)));
  }

  Future<void> playSongAtIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  Future<void> play() async {
    ///error?
    await ensureActive() ? await _player.play() : null;
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
