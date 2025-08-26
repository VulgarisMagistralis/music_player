import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_card.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/pages/error_pages/generic_error_page.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> with WidgetsBindingObserver {
  final List<String> _directories = SharedPreferenceWithCacheHandler.instance.getMusicFolderList();
  late final ScrollController scrollController;
  bool playlistSet = false;
  final String _playlistId = 'songs';
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
        onAttach: (position) => WidgetsBinding.instance.addPostFrameCallback((__) => position.animateTo(ref.read(songsPageScrollOffsetProvider.notifier).value,
            curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: (ref.read(songsPageScrollOffsetProvider.notifier).value * 0.65).floor()))));
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
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PlayerHeader(),
                Expanded(
                    flex: 8,
                    child: ref.watch(readSongFileListProvider(_directories)).when(
                        data: (List<FileSystemEntity> musicFileList) {
                          if (musicFileList.length > 0) ToastManager().showInfoToast('Loaded ${musicFileList.length} files');
                          final songs = musicFileList.map((file) => {'file': file, 'title': file.uri.pathSegments.last.replaceAll('.mp3', '')}).toList();
                          return ListView.builder(
                              shrinkWrap: true,
                              cacheExtent: 100.0,
                              itemCount: songs.length,
                              controller: scrollController,
                              itemBuilder: (_, index) => Column(children: [
                                    GestureDetector(
                                        child: AnimatedOverflowText(text: songs[index]['title'] as String),
                                        onTap: () async {
                                          final PlayerAudioHandler audioHandler = ref.read(audioHandlerProvider);
                                          if (playlistSet) {
                                            await audioHandler.playSongAtIndex(index);
                                          } else {
                                            await audioHandler.setPlaylist(_playlistId, index: index, songs.map((map) => map['file'] as FileSystemEntity).toList(), songs.map((map) => map['title'] as String).toList());
                                            setState(() => playlistSet = true);
                                          }
                                        })
                                  ]));
                        },
                        error: (error, _) => GenericErrorPage(message: 'Failed to load music files'),
                        loading: () => const Center(child: CircularProgressIndicator()))),
                const SongCard()
              ]))));
}
