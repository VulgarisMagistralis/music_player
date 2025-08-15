import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/route/routes.dart';

void main() {
  testWidgets('Nav bar tests', (tester) async {
    late PlayerPageEnum lastState;

    final testProvider = PlayerRoute();

    await tester.pumpWidget(ProviderScope(overrides: [
      playerRouteProvider.overrideWith(() => testProvider),
    ], child: const MaterialApp(home: Scaffold(body: PlayerNavigationBar()))));

    final buttonsToRoutes = {
      Icons.search: PlayerPageEnum.search,
      Icons.music_note_outlined: PlayerPageEnum.songs,
      Icons.settings_outlined: PlayerPageEnum.settings,
      Icons.favorite_outline_sharp: PlayerPageEnum.favourites,
      Icons.featured_play_list_outlined: PlayerPageEnum.playlists
    };

    for (final entry in buttonsToRoutes.entries) {
      testProvider.stream.listen((state) => lastState = state);
      await tester.tap(find.widgetWithIcon(IconButton, entry.key));
      await tester.pump();
      expect(lastState, entry.value);
    }
  });
}
