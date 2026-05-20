import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';
import 'package:music_player/utilities/sort_extensions.dart';

void main() {
  group('SortBy - toggle functions', () {
    group('toggleName', () {
      test('toggles between name ascending and descending', () {
        var current = SortBy.nameAscending;
        current = current.toggleName();
        expect(current, SortBy.nameDescending);

        current = current.toggleName();
        expect(current, SortBy.nameAscending);
      });

      test('returns nameAscending for other modes', () {
        expect(SortBy.durationAscending.toggleName(), SortBy.nameAscending);
        expect(SortBy.dateModifiedDescending.toggleName(), SortBy.nameAscending);
      });
    });

    group('toggleDuration', () {
      test('toggles between duration ascending and descending', () {
        var current = SortBy.durationAscending;
        current = current.toggleDuration();
        expect(current, SortBy.durationDescending);

        current = current.toggleDuration();
        expect(current, SortBy.durationAscending);
      });

      test('returns durationAscending for other modes', () {
        expect(SortBy.nameAscending.toggleDuration(), SortBy.durationAscending);
        expect(SortBy.dateModifiedDescending.toggleDuration(), SortBy.durationAscending);
      });
    });

    group('toggleDate', () {
      test('toggles between date ascending and descending', () {
        var current = SortBy.dateModifiedAscending;
        current = current.toggleDate();
        expect(current, SortBy.dateModifiedDescending);

        current = current.toggleDate();
        expect(current, SortBy.dateModifiedAscending);
      });

      test('returns dateModifiedAscending for other modes', () {
        expect(SortBy.nameAscending.toggleDate(), SortBy.dateModifiedAscending);
        expect(SortBy.durationDescending.toggleDate(), SortBy.dateModifiedAscending);
      });
    });
  });

  group('SortByDisplay', () {
    test('returns correct labels for all modes', () {
      expect(SortBy.nameAscending.label, 'Name ↑');
      expect(SortBy.nameDescending.label, 'Name ↓');
      expect(SortBy.durationAscending.label, 'Duration ↑');
      expect(SortBy.durationDescending.label, 'Duration ↓');
      expect(SortBy.dateModifiedAscending.label, 'Date ↑');
      expect(SortBy.dateModifiedDescending.label, 'Date ↓');
    });
  });
}
