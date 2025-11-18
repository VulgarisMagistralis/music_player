import 'package:music_player/src/rust/api/utils/sort_modes.dart';

extension SortByToggle on SortBy {
  SortBy toggleName() {
    switch (this) {
      case SortBy.nameAscending:
        return SortBy.nameDescending;
      case SortBy.nameDescending:
        return SortBy.nameAscending;
      default:
        return SortBy.nameAscending;
    }
  }

  SortBy toggleDuration() {
    switch (this) {
      case SortBy.durationAscending:
        return SortBy.durationDescending;
      case SortBy.durationDescending:
        return SortBy.durationAscending;
      default:
        return SortBy.durationAscending;
    }
  }

  SortBy toggleDate() {
    switch (this) {
      case SortBy.dateModifiedAscending:
        return SortBy.dateModifiedDescending;
      case SortBy.dateModifiedDescending:
        return SortBy.dateModifiedAscending;
      default:
        return SortBy.dateModifiedAscending;
    }
  }
}

extension SortByDisplay on SortBy {
  String get label {
    switch (this) {
      case SortBy.nameAscending:
        return 'Name ↑';
      case SortBy.nameDescending:
        return 'Name ↓';

      case SortBy.durationAscending:
        return 'Duration ↑';
      case SortBy.durationDescending:
        return 'Duration ↓';

      case SortBy.dateModifiedAscending:
        return 'Date ↑';
      case SortBy.dateModifiedDescending:
        return 'Date ↓';
    }
  }
}
