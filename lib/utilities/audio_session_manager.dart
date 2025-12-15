import 'dart:io' show FileSystemEntity;
import 'dart:typed_data' show Uint8List;
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'audio_session_manager.g.dart';

@Riverpod(keepAlive: true)
class AudioSessionManager extends Notifier<AudioSessionState?> {
  @override
  AudioSessionState? build() => SharedPreferenceWithCacheHandler.instance.loadSongState();

  Future<void> saveState() async {
    if (state == null) return;
    print('SAvING STATE ${state}');
    await SharedPreferenceWithCacheHandler.instance.saveSongState(state!);
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
    if (state == null) return;
    state = state?.copyWith(
      playlistId: playlistId ?? state!.playlistId,
      songId: songId ?? state!.songId,
      file: file,
      title: title,
      songIndexInPlaylist: songIndexInPlaylist ?? state!.songIndexInPlaylist,
      isPlaying: isPlaying ?? state!.isPlaying,
      isReady: isReady ?? state!.isReady,
      playlistScrollOffset: playlistScrollOffset ?? state!.playlistScrollOffset,
      albumArt: albumArt,
      asMediaItem: asMediaItem,
      favouritePlaylistIndexOrNull: favouritePlaylistIndexOrNull,
    );
    await saveState();
  }
}
