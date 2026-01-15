import 'package:flutter/material.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Songs, PLaylists, Favourites, Search Settings
class PlayerNavigationBar extends ConsumerStatefulWidget {
  const PlayerNavigationBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigationBarState();
}

class _NavigationBarState extends ConsumerState<PlayerNavigationBar> {
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      child: Row(
        children: [
          IconButton(onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.songs), icon: const Icon(Icons.music_note_outlined)),
          const Spacer(),
          ...ref
              .watch(getFavouritesPlaylistProvider)
              .when(
                error: (__, _) => [const SizedBox.shrink()],
                loading: () => [const SizedBox.shrink()],
                data: (playlist) => playlist.songIdList.isEmpty
                    ? []
                    : [IconButton(onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.favourites), icon: const Icon(Icons.favorite_outline_sharp)), const Spacer()],
              ),
          IconButton(onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.playlists), icon: const Icon(Icons.featured_play_list_outlined)),
          const Spacer(),
          IconButton(onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.search), icon: const Icon(Icons.search)),
          const Spacer(),
          IconButton(onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.settings), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
    ),
  );
}
