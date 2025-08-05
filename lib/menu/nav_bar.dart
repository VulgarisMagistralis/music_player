import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/route/routes.dart';

/// Songs, PLaylists, Favourites (only if at least a song is added to favs), Settings
///
class PlayerNavigationBar extends ConsumerStatefulWidget {
  const PlayerNavigationBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigationBarState();
}

class _NavigationBarState extends ConsumerState<PlayerNavigationBar> {
  @override
  Widget build(BuildContext context) => SafeArea(
          child: SizedBox(
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
            onPressed: () {
              ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.songs);
            },
            icon: const Icon(Icons.music_note_outlined)),
        IconButton(
            onPressed: () {
              ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.favourites);
            },
            icon: const Icon(Icons.favorite_outline_sharp)), //....
        IconButton(
            onPressed: () {
              ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.playlists);
            },
            icon: const Icon(Icons.featured_play_list_outlined)),
        IconButton(
            onPressed: () {
              ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.search);
            },
            icon: const Icon(Icons.search)),
        IconButton(
            onPressed: () {
              ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.settings);
            },
            icon: const Icon(Icons.settings_outlined)),
      ])));
}
