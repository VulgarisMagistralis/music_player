import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/src/rust/api/process_music.dart';
import 'package:music_player/src/rust/api/data/playlist.dart';
import 'package:music_player/src/rust/api/song_collection.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/src/rust/api/data/song.dart' show Song;
import 'package:music_player/low_level_wrapper/data/datasource/music_folder.dart';
import 'package:music_player/low_level_wrapper/data/repository/folder_repo_imp.dart';
part 'providers.g.dart';

@Riverpod(keepAlive: true)
class SongsPageScrollOffset extends _$SongsPageScrollOffset {
  @override
  double build() => state = 0.0;
  double get value => state;
  void updateOffset(double newOffset) => state = newOffset;
}

@Riverpod(keepAlive: true)
Future<List<String>> loadLibrary(Ref ref) async => await LowLevelRepositoryImplementation().loadFolderList();

@Riverpod(keepAlive: true)
Future<void> saveLibrary(Ref ref, List<String> folderList) async => await LowLevelRepositoryImplementation().saveFolderList(folderList: folderList);

@Riverpod(keepAlive: true)
Future<void> deleteLibrary(Ref ref, String folder) async => await LowLevelRepositoryImplementation().deleteFolder(folder: folder);

@Riverpod(keepAlive: true)
Future<List<Song>> allSongs(Ref ref) async => await getAllSongsFromCollection();

@Riverpod(keepAlive: true)
Future<Uint8List?> albumArt(Ref ref, BigInt id) async => await getSongAlbumArt(id: id);

@Riverpod(keepAlive: true)
Stream<StreamEvent> processMusicFiles(Ref ref) async* {
  yield* readMusicFiles();
}

@Riverpod(keepAlive: true)
Future<List<Song>> sortedSongList(Ref ref) async {
  final sortBy = ref.watch(playlistSortedByProvider);
  return getSortedSongs(sort: sortBy);
}

final AsyncNotifierProvider<AudioSessionManager, AudioSessionState?> audioSessionManagerProvider = AsyncNotifierProvider<AudioSessionManager, AudioSessionState?>(() => AudioSessionManager());

final Provider<PlayerAudioHandler> audioHandlerProvider = Provider<PlayerAudioHandler>((ref) => PlayerAudioHandler());

@Riverpod(keepAlive: true)
Future<List<String>> getSavedFolderList(Ref ref) => LowLevelFolderDataSource().loadFolders();

@Riverpod(keepAlive: true)
PlaylistCollection playlistCollection(Ref ref) => PlaylistCollection();

//todo
// @Riverpod(keepAlive: true)
// class FavouriteSongList extends _$FavouriteSongList {
//   @override
//   List build() => state = [];
//   List get value => state;
//   void addSong(var newSong) => state.add(newSong);
//   void removeSong(var songToRemove) => state.remove(songToRemove);
// }

@Riverpod(keepAlive: true)
class PlaylistSortedBy extends _$PlaylistSortedBy {
  @override
  SortBy build() => state = SortBy.dateModifiedDescending;
  SortBy get value => state;
  void update(SortBy newSortingRule) => state = newSortingRule;
}
