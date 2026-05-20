import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/utilities/song_sorting.dart';

part 'songs_loading_provider.g.dart';

class SongsLoading {
  final List<Song> songs;
  final bool scanning;
  final String? error;
  final bool hasScanned;

  SongsLoading({this.songs = const [], this.scanning = true, this.error, this.hasScanned = false});

  SongsLoading copyWith({List<Song>? songs, bool? scanning, String? error, bool? hasScanned}) {
    return SongsLoading(
      songs: songs ?? this.songs,
      scanning: scanning ?? this.scanning,
      error: error,
      hasScanned: hasScanned ?? this.hasScanned,
    );
  }
}

@Riverpod(keepAlive: true)
class SongsLoadingNotifier extends _$SongsLoadingNotifier {
  @override
  SongsLoading build() {
    // Capture current sort mode so we can use it safely inside async callbacks
    // (ref methods cannot be called outside the build phase)
    SortBy currentSort = ref.watch(playlistSortedByProvider);

    // Watch sort mode changes - re-sort when it changes
    ref.listen(playlistSortedByProvider, (_, SortBy? next) {
      if (next != null) {
        currentSort = next;
        final sorted = state.songs.sortedBy(next);
        state = state.copyWith(songs: sorted);
      }
    });

    // Listen to processMusicFilesProvider stream
    ref.listen(processMusicFilesProvider, (_, next) {
      // Reset state when the stream source rebuilds (e.g. threshold change)
      state = state.copyWith(songs: [], scanning: true, error: null, hasScanned: false);

      next.whenData((event) {
        if (event is StreamEvent_Song) {
          final map = Map<BigInt, Song>.fromEntries(state.songs.map((s) => MapEntry(s.id, s)));
          map[event.field0.id] = event.field0; // upsert
          final songs = map.values.toList();
          songs.sortBy(currentSort);
          state = state.copyWith(songs: songs);
        } else if (event is StreamEvent_Error) {
          state = state.copyWith(error: event.field0);
        } else if (event is StreamEvent_Done) {
          state = state.copyWith(scanning: false, hasScanned: true);
          // Invalidate the favourites bootstrap so it re-queries the (now-pruned) collection
          ref.invalidate(favouriteSongsBootstrapProvider);
        }
      });
    });

    return SongsLoading();
  }
}
