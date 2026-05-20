import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';

extension SortSongs on List<Song> {
  void sortBy(SortBy sort) {
    sortSongList(this, sort);
  }

  List<Song> sortedBy(SortBy sort) {
    final copy = toList();
    sortSongList(copy, sort);
    return copy;
  }
}

void sortSongList(List<Song> list, SortBy sort) {
  switch (sort) {
    case SortBy.nameAscending:
      list.sort((a, b) => a.title.compareTo(b.title));
    case SortBy.nameDescending:
      list.sort((a, b) => b.title.compareTo(a.title));
    case SortBy.durationAscending:
      list.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
    case SortBy.durationDescending:
      list.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
    case SortBy.dateModifiedAscending:
      list.sort((a, b) => a.lastModifiedAt.compareTo(b.lastModifiedAt));
    case SortBy.dateModifiedDescending:
      list.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));
  }
}
