import 'dart:io' show FileSystemEntity;
import 'dart:typed_data' show Uint8List;
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'audio_session_manager.g.dart';

@Riverpod(keepAlive: true)
class AudioSessionManager extends Notifier<AudioSessionState> {
  final base = AudioSessionState.initial();
  @override
  AudioSessionState build() => SharedPreferenceWithCacheHandler.instance.loadSongState() ?? base;

  Future<void> saveState() async => await SharedPreferenceWithCacheHandler.instance.saveSongState(state);

  void _validate(AudioSessionState s) {
    if (s.isReady) {
      assert(s.songId != null, 'Ready state without songId');
      assert(s.asMediaItem != null, 'Ready state without MediaItem');
    }

    if (s.isPlaying) {
      assert(s.file != null, 'Playing without file');
    }
  }

  void updateFromMediaItem(MediaItem mediaItem, int index) async {
    state = state.copyWith(songId: BigInt.parse(mediaItem.id), title: mediaItem.title, songIndexInPlaylist: index, asMediaItem: mediaItem, isReady: true);
    await saveState();
  }

  Future<void> updateState({
    String? playlistId,
    BigInt? songId,
    FileSystemEntity? file,
    String? title,
    int? songIndexInPlaylist,
    bool? isPlaying,
    bool? isReady,
    double? playlistScrollOffset,
    Uint8List? albumArt,
    MediaItem? asMediaItem,
    int? favouritePlaylistIndexOrNull,
  }) async {
    final nextState = base.copyWith(
      playlistId: playlistId ?? base.playlistId,
      songId: songId ?? base.songId,
      file: file,
      title: title,
      songIndexInPlaylist: songIndexInPlaylist ?? base.songIndexInPlaylist,
      isPlaying: isPlaying ?? base.isPlaying,
      isReady: isReady ?? base.isReady,
      playlistScrollOffset: playlistScrollOffset ?? base.playlistScrollOffset,
      albumArt: albumArt,
      asMediaItem: asMediaItem,
      favouritePlaylistIndexOrNull: favouritePlaylistIndexOrNull,
    );

    _validate(nextState);
    state = nextState;
    await saveState();
  }
}
