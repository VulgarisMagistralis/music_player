import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:music_player/src/rust/api/playlist_collection.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/image_resize.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/src/rust/api/process_music.dart';
import 'package:music_player/src/rust/api/data/playlist.dart';
import 'package:music_player/src/rust/api/song_collection.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
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
Future<Uint8List?> albumArt(Ref ref, BigInt id) async {
  final rawBytes = await getSongAlbumArt(id: id);
  return rawBytes == null ? null : await compute(resizeAlbumArt, rawBytes);
}

@Riverpod(keepAlive: true)
Stream<StreamEvent> processMusicFiles(Ref ref) async* {
  yield* readMusicFiles();
}

@Riverpod(keepAlive: true)
Future<List<Song>> sortedSongList(Ref ref) async {
  final sortBy = ref.watch(playlistSortedByProvider);
  return getSortedSongs(sort: sortBy);
}

@Riverpod(keepAlive: true)
PlayerAudioHandler audioHandler(Ref ref) => PlayerAudioHandler();

@Riverpod(keepAlive: true)
Future<List<String>> getSavedFolderList(Ref ref) => LowLevelFolderDataSource().loadFolders();

@Riverpod(keepAlive: true)
Future<List<Playlist>> playlistCollection(Ref ref) async => await getAllPlaylistsFromCollection();

@Riverpod(keepAlive: true)
Future<void> deletePlaylistFromCollection(Ref ref, {required BigInt playlistId}) async => await deletePlaylist(playlistId: playlistId);

@Riverpod(keepAlive: false)
Future<Playlist> addPlaylist(Ref ref, {required String newPlaylistName}) async => await addPlaylistToCollection(name: newPlaylistName);

@Riverpod(keepAlive: true)
Future<List<Song>> getPlaylistSongs(Ref ref, {required Playlist playlist}) async => await getSongList(idList: playlist.songIdList);

@Riverpod(keepAlive: true)
class PlaylistSortedBy extends _$PlaylistSortedBy {
  @override
  SortBy build() => state = SortBy.dateModifiedDescending;
  SortBy get value => state;
  void update(SortBy newSortingRule) => state = newSortingRule;
}
