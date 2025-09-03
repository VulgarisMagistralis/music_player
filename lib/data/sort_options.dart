import 'package:music_player/utilities/string_extension.dart';

enum SortBy {
  nameAscending,
  nameDescending,
  durationAscending,
  durationDescending,
  dateModifiedAscending,
  dateModifiedDescending;

  @override
  String toString() => name.camelCaseToSpaced.reverseWordOrder;
  SortBy toggleName() => this == SortBy.nameAscending ? SortBy.nameDescending : SortBy.nameAscending;
  SortBy toggleDuration() => this == SortBy.durationAscending ? SortBy.durationDescending : SortBy.durationAscending;
  SortBy toggleDate() => this == SortBy.dateModifiedAscending ? SortBy.dateModifiedDescending : SortBy.dateModifiedAscending;
}
