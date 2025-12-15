import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/song_row.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/widgets/loading_animation.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/pages/error_pages/generic_error_page.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      onAttach: (position) => WidgetsBinding.instance.addPostFrameCallback(
        (__) => position.animateTo(
          ref.read(songsPageScrollOffsetProvider.notifier).value,
          curve: Curves.fastOutSlowIn,
          duration: Duration(milliseconds: (ref.read(songsPageScrollOffsetProvider.notifier).value * 0.65).floor()),
        ),
      ),
    );
    _scrollController.addListener(() => ref.read(songsPageScrollOffsetProvider.notifier).updateOffset(_scrollController.offset));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(processMusicFilesProvider, (_, next) {
      next.whenData((event) {
        if (event is StreamEvent_Done) {
          ref.invalidate(playlistSortedByProvider);
          ref.invalidate(allSongsProvider);
          ref.invalidate(sortedSongListProvider);
        }
      });
    });
    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlayerHeader(showExtraButtons: true),
              const SizedBox(height: 10),
              Expanded(
                flex: 10,
                child: ref.watch(processMusicFilesProvider).isLoading
                    ? const Center(child: WaveformLoading())
                    : ref
                          .watch(sortedSongListProvider)
                          .when(
                            data: (List<Song> sortedSongList) {
                              return sortedSongList.isEmpty
                                  ? GenericErrorPage(
                                      message: 'Couldn\'t find any music',
                                      actionWidget: ElevatedButton.icon(
                                        onPressed: () => ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.settings),
                                        icon: const Icon(Icons.settings),
                                        label: const Text('Settings'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                                      ),
                                      showNavigation: true,
                                    )
                                  : ListView.builder(
                                      itemCount: sortedSongList.length,
                                      controller: _scrollController,
                                      itemBuilder: (_, index) => SongRow(
                                        key: ValueKey(sortedSongList[index].id), // IMPORTANT
                                        song: sortedSongList[index],
                                        index: index,
                                        onTap: (int i) async {
                                          final handler = ref.read(audioHandlerProvider);
                                          await handler.setPlaylist('songs', sortedSongList, index: i);
                                          await ref
                                              .read(audioSessionManagerProvider.notifier)
                                              .updateState(songIndexInPlaylist: index, file: File(sortedSongList[index].path), title: sortedSongList[index].title, songId: sortedSongList[index].id);
                                        },
                                      ),
                                    );
                            },
                            error: (error, stackTrace) => const SizedBox.shrink(),
                            loading: () => const Center(child: WaveformLoading()),
                          ),
              ),
              const SongCard(),
            ],
          ),
        ),
      ),
    );
  }
}
