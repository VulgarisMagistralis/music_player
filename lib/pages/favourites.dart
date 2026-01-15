import 'package:flutter/material.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/song_row.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/src/rust/api/data/song.dart';

/// Determine app state and reroute
/// check file read permission
class FavouritesPage extends ConsumerStatefulWidget {
  const FavouritesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends ConsumerState<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    final List<Song> songList = ref.watch(favouriteSongsProvider);
    ref.listen(favouriteSongsProvider, (_, next) => next.isEmpty ? ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.songs) : null);
    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            children: [
              const PlayerHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: songList.length,
                  itemBuilder: (_, index) => SongRow(
                    key: ValueKey(songList[index].id),
                    song: songList[index],
                    index: index,
                    onTap: (int i) async => await ref.read(audioHandlerProvider).setPlaylist('favs', songList, index: i),
                  ),
                ),
              ),
              const NowPlaying(),
            ],
          ),
        ),
      ),
    );
  }
}
