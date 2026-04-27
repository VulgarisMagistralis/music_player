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
    final songId = BigInt.tryParse(mediaItem.extras?['songId'] as String? ?? '');
    state = state.copyWith(songId: songId, title: mediaItem.title, songIndexInPlaylist: index, asMediaItem: mediaItem, isReady: true);
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
    final nextState = state.copyWith(
      playlistId: playlistId ?? state.playlistId,
      songId: songId ?? state.songId,
      file: file ?? state.file,
      title: title ?? state.title,
      songIndexInPlaylist: songIndexInPlaylist ?? state.songIndexInPlaylist,
      isPlaying: isPlaying ?? state.isPlaying,
      isReady: isReady ?? state.isReady,
      playlistScrollOffset: playlistScrollOffset ?? state.playlistScrollOffset,
      albumArt: albumArt ?? state.albumArt,
      asMediaItem: asMediaItem ?? state.asMediaItem,
      favouritePlaylistIndexOrNull: favouritePlaylistIndexOrNull ?? state.favouritePlaylistIndexOrNull,
    );
    _validate(nextState);
    state = nextState;
    await saveState();
  }
}
