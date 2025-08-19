import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/common/animated_card.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:audio_session/audio_session.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/settings_data.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> with WidgetsBindingObserver {
  final List<String> _directories = SharedPreferenceWithCacheHandler.instance.getMusicFolderList();
  late final ScrollController scrollController;
  bool hasRestoredScroll = false;
  bool playlistSet = false;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
        onAttach: (_) => WidgetsBinding.instance.addPostFrameCallback((__) {
              double lastOffset = ref.read(songsPageScrollOffsetProvider.notifier).value;
              _.animateTo(lastOffset, curve: Curves.bounceOut, duration: Duration(milliseconds: (lastOffset * 0.75).floor()));
            }));
    scrollController.addListener(() => ref.read(songsPageScrollOffsetProvider.notifier).updateOffset(scrollController.offset));
    WidgetsBinding.instance.addObserver(this);
    //! check
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
        androidAudioAttributes: AndroidAudioAttributes(contentType: AndroidAudioContentType.music, flags: AndroidAudioFlags.none)));
    // ref.watch(currentSongProvider).audioPlayer.errorStream.listen((e) {
    //   print('A stream error occurred: $e');
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    // player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      // player.stop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const PlayerNavigationBar(),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(15, 15, 10, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PlayerHeader(),
                Expanded(
                    flex: 8,
                    child: ref.watch(readSongFileListProvider(_directories)).when(
                        data: (musicFileList) {
                          final songs = musicFileList.map((file) => {'file': file, 'title': file.uri.pathSegments.last.replaceAll('.mp3', '')}).toList();

                          return ListView.builder(
                              shrinkWrap: true,
                              cacheExtent: 100.0,
                              itemCount: songs.length,
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                              itemBuilder: (BuildContext context, int index) => Column(children: [
                                    GestureDetector(
                                        child: AnimatedOverflowText(text: songs[index]['title'].toString()),
                                        onTap: () async {
                                          final manager = ref.read(audioSessionManagerProvider.notifier);
                                          if (playlistSet) {
                                            await manager.playSongAtIndex(index);
                                          } else {
                                            await manager.setPlaylist(index: index, songs.map((_) => _['file'] as FileSystemEntity).toList(), songs.map((_) => _['title'] as String).toList());
                                          }
                                        })
                                  ]));
                        },
                        error: (error, stackTrace) => const Text('error '),
                        loading: () => const Center(child: CircularProgressIndicator()))),
                const SongCard()
              ]))));
}
