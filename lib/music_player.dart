import 'package:flutter/material.dart';
import 'package:music_player/pages/songs.dart';
import 'package:music_player/pages/search.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/pages/settings.dart';
import 'package:music_player/pages/playlists.dart';
import 'package:music_player/pages/error_page.dart';
import 'package:music_player/pages/favourites.dart';
import 'package:music_player/theme/theme_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: playerThemeData,
      builder: (context, child) => switch (ref.watch(playerRouteProvider)) {
            PlayerPageEnum.songs => const SongsPage(),
            PlayerPageEnum.error => const ErrorPage(),
            PlayerPageEnum.search => const SearchPage(),
            PlayerPageEnum.settings => const SettingsPage(),
            PlayerPageEnum.playlists => const PlaylistPage(),
            PlayerPageEnum.favourites => const FavouritesPage()
          });
}
