import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/song.dart';
import 'package:music_player/data/position.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter/material.dart' show WidgetsBindingObserver;

class AudioSessionManager extends AsyncNotifier<AudioSessionState?> with WidgetsBindingObserver {
  late final PlayerAudioHandler _handler;
  final List<UriAudioSource> _sources = [];
  List<UriAudioSource> get queue => _sources;
  PlayerAudioHandler get handler => _handler;
  String get songName => state.value?.title ?? '';

  Future<void> updateState() async {
    AudioSessionState? newState = AsyncData(state).value.value;
    if (newState == null) return;
    await SharedPreferenceWithCacheHandler.instance.saveSongState(newState);
  }

  Stream<PositionData> get positionStream => ref.read(audioHandlerProvider).positionDataStream;

  @override
  Future<AudioSessionState> build() async {
    state = AsyncData(state.value ?? AsyncData(await SharedPreferenceWithCacheHandler.instance.loadSongState()).value ?? AudioSessionState.initial());
    _handler = ref.read(audioHandlerProvider);
    _handler.mediaItem.listen((MediaItem? newMediaItem) {
      if (newMediaItem == null) return;
      state = AsyncData(state.value!.copyWith(title: newMediaItem.title, asMediaItem: newMediaItem, isReady: true));
      SharedPreferenceWithCacheHandler.instance.saveSongState(state.value!);
    });
    _handler.playbackState.listen((PlaybackState playbackState) {
      state = AsyncData(state.value!.copyWith(isPlaying: playbackState.playing));
      SharedPreferenceWithCacheHandler.instance.saveSongState(state.value!);
    });
    return state.value!;
  }
}
