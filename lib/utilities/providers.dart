import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/src/rust/api/data/playlist.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/src/rust/api/data/song.dart' show Song, SongCollection;
import 'package:music_player/low_level_wrapper/data/datasource/music_folder.dart';
part 'providers.g.dart';

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
Future<List<String>> getSavedFolderList(Ref ref) => LowLevelFolderDataSource().loadFolders();

@Riverpod(keepAlive: true)
Future<List<Song>> totalSongList(Ref ref) async {
  final songCollection = ref.watch(songCollectionProvider);
  return songCollection.getAllSongs();
}

@Riverpod(keepAlive: true)
SongCollection songCollection(Ref ref) => SongCollection();

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

@Riverpod(keepAlive: true)
Future<List<Song>> sortedSongList(Ref ref) async {
  final sortBy = ref.watch(playlistSortedByProvider);
  final songCollection = ref.watch(songCollectionProvider);
  return songCollection.getAllSorted(sortBy: sortBy);
}
