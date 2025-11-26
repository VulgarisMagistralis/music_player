import 'package:flutter/material.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/widgets/loading_animation.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
import 'package:music_player/pages/error_pages/generic_error_page.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> with WidgetsBindingObserver {
  late final ScrollController scrollController;
  bool playlistSet = false;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      onAttach: (position) => WidgetsBinding.instance.addPostFrameCallback(
        (__) => position.animateTo(
          ref.read(songsPageScrollOffsetProvider.notifier).value,
          curve: Curves.fastOutSlowIn,
          duration: Duration(milliseconds: (ref.read(songsPageScrollOffsetProvider.notifier).value * 0.65).floor()),
        ),
      ),
    );
    scrollController.addListener(() => ref.read(songsPageScrollOffsetProvider.notifier).updateOffset(scrollController.offset));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(processMusicFilesProvider, (prev, next) {
      next.whenData((event) {
        switch (event.runtimeType) {
          case StreamEvent_Song:
            ref.invalidate(playlistSortedByProvider);
            ref.invalidate(allSongsProvider);
            ref.invalidate(sortedSongListProvider);
          case StreamEvent_Error:
            break;
          case StreamEvent_Done:
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
                            data: (sortedSongList) {
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
                                      shrinkWrap: true,
                                      cacheExtent: 100.0,
                                      itemCount: sortedSongList.length,
                                      controller: scrollController,
                                      itemBuilder: (_, index) => Column(
                                        children: [
                                          Row(
                                            children: [
                                              ref
                                                  .watch(albumArtProvider(sortedSongList[index].id))
                                                  .when(
                                                    data: (bytes) => SizedBox(width: 50, height: 50, child: bytes != null ? Image.memory(bytes, fit: BoxFit.cover) : const SizedBox.shrink()),
                                                    error: (error, stackTrace) => const SizedBox.shrink(),
                                                    loading: () => const CircularProgressIndicator(),
                                                  ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: GestureDetector(
                                                  child: AnimatedOverflowText(text: sortedSongList[index].title),
                                                  onTap: () async {
                                                    final PlayerAudioHandler audioHandler = ref.read(audioHandlerProvider);
                                                    if (playlistSet) {
                                                      await audioHandler.playSongAtIndex(index);
                                                    } else {
                                                      await audioHandler.setPlaylist('songs', sortedSongList, index: index);
                                                      setState(() => playlistSet = true);
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  false
                                                      // songList[index].isInFavourites
                                                      ? Icons.favorite_sharp
                                                      : Icons.favorite_border,
                                                ),
                                                onPressed: () => setState(
                                                  () => null, // songList[index] =
                                                  //     Song.toggleFavourite(
                                                  //         songList[index])
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
