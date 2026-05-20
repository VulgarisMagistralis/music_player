import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/route/routes.dart';

void main() {
  group('PlayerPageEnum', () {
    test('all pages have names', () {
      expect(PlayerPageEnum.values.length, greaterThan(0));

      for (final page in PlayerPageEnum.values) {
        expect(page.name, isNotNull);
        expect(page.name, isNotEmpty);
      }
    });

    test('has expected pages', () {
      final names = PlayerPageEnum.values.map((e) => e.name).toList();

      expect(names, contains('songs'));
      expect(names, contains('favourites'));
      expect(names, contains('playlists'));
      expect(names, contains('search'));
      expect(names, contains('settings'));
    });
  });
}
