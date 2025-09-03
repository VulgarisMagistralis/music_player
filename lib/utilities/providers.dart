import 'dart:io';
import 'package:music_player/data/playlist.dart';
import 'package:music_player/data/sort_options.dart';
import 'package:music_player/data/song.dart' show Song;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/utilities/settings_data.dart' show SharedPreferenceWithCacheHandler;
part 'providers.g.dart';

@riverpod
Stream readFiles(Ref ref, Directory musicDirectory) => musicDirectory.list(followLinks: false);

@Riverpod(keepAlive: true, dependencies: [totalSongList])
AsyncValue<Playlist> allSongsPlaylist(Ref ref) => ref.watch(totalSongListProvider).whenData(
      (songs) => Playlist(id: 'songs', name: 'All Songs', songIdList: songs.map((Song song) => song.id).toList()),
    );

@Riverpod(keepAlive: true)
class SongsPageScrollOffset extends _$SongsPageScrollOffset {
  @override
  double build() => state = 0.0;
  double get value => state;
  void updateOffset(double newOffset) => state = newOffset;
}

final AsyncNotifierProvider<AudioSessionManager, AudioSessionState?> audioSessionManagerProvider = AsyncNotifierProvider<AudioSessionManager, AudioSessionState?>(() => AudioSessionManager());
final Provider<PlayerAudioHandler> audioHandlerProvider = Provider<PlayerAudioHandler>((ref) => PlayerAudioHandler());
@Riverpod(keepAlive: true)
List<String> getSavedFolderList(Ref ref) => SharedPreferenceWithCacheHandler.instance.getMusicFolderList();

@Riverpod(keepAlive: true, dependencies: [getSavedFolderList])
Future<List<Song>> totalSongList(Ref ref) async {
  final List<String> musicDirectoryList = ref.watch(getSavedFolderListProvider);
  final List<Song> songs = [];

  for (final dirPath in musicDirectoryList) {
    final Directory dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    await for (final FileSystemEntity file in dir.list(recursive: true, followLinks: false)) {
      final String path = file.path.toLowerCase();
      //? webm issue?
      if (file is File && (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.webm'))) songs.add(Song.create(file: file));
    }
  }
  return songs;
}

//todo
@Riverpod(keepAlive: true)
class FavouriteSongList extends _$FavouriteSongList {
  @override
  List build() => state = [];
  List get value => state;
  void addSong(var newSong) => state.add(newSong);
  void removeSong(var songToRemove) => state.remove(songToRemove);
}

//make per playlist
@Riverpod(keepAlive: true)
class PlaylistSortedBy extends _$PlaylistSortedBy {
  String playlistId = 'songs';
  @override
  SortBy build() => state = SortBy.nameAscending;
  SortBy get value => state;
  void update(SortBy newSortingRule) => state = newSortingRule;
}
