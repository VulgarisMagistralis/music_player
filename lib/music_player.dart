import 'package:flutter/material.dart';
import 'package:music_player/pages/songs.dart';
import 'package:music_player/pages/search.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/pages/settings.dart';
import 'package:music_player/pages/playlists.dart';
import 'package:music_player/pages/favourites.dart';
import 'package:music_player/pages/loading_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/theme/theme_providers.dart';
import 'package:music_player/pages/error_pages/generic_error_page.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: ref.watch(playerThemeProvider),
      debugShowCheckedModeBanner: false,
      home: switch (ref.watch(playerRouteProvider)) {
        PlayerPageEnum.songs => const SongsPage(),
        PlayerPageEnum.error => GenericErrorPage(),
        PlayerPageEnum.search => const SearchPage(),
        PlayerPageEnum.loading => const LoadingPage(),
        PlayerPageEnum.settings => const SettingsPage(),
        PlayerPageEnum.playlists => const PlaylistPage(),
        PlayerPageEnum.favourites => const FavouritesPage()
      });
}
