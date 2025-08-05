import 'dart:io';
import 'package:music_player/widgets/song_card.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/common/common.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/widgets/header.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> with WidgetsBindingObserver {
  final _directories = SharedPreferenceWithCacheHandler.instance.getMusicFolderList();
  AudioPlayer player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // ref.watch(currentSongProvider).audioPlayer.errorStream.listen((e) {
    //   print('A stream error occurred: $e');
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // player.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     // Release the player's resources when not in use. We use "stop" so that
  //     // if the app resumes later, it will still remember what position to
  //     // resume from.
  //     player.stop();
  //   }
  // }
  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      player.positionStream, player.bufferedPositionStream, player.durationStream, (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            final songs = musicFileList.map((file) {
                              final name = file.uri.pathSegments.last.replaceAll('.mp3', '');
                              return {'file': file, 'title': name};
                            }).toList();
                            return ListView.builder(
                                padding: const EdgeInsets.all(0.0),
                                itemCount: songs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final song = songs[index];
                                  return Column(children: [
                                    Text(song['title'].toString()),
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          ref.read(getSongTitle.notifier).updateTitle(song['title'] as String);
                                          await player.clearAudioSources();
                                          await player.setAudioSource(AudioSource.file((song['file'] as FileSystemEntity).path));
                                          await player.play();
                                          setState(() {});
                                        } on PlayerException catch (e) {
                                          print("Error loading audio source: $e");
                                        }
                                      },
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                    StreamBuilder<PositionData>(
                                      stream: _positionDataStream,
                                      builder: (context, snapshot) {
                                        final positionData = snapshot.data;
                                        return SeekBar(
                                          duration: positionData?.duration ?? Duration.zero,
                                          position: positionData?.position ?? Duration.zero,
                                          bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                                          onChangeEnd: player.seek,
                                        );
                                      },
                                    )
                                  ]);
                                });
                          },

                          ///TODO error page
                          error: (error, stackTrace) => const Text('a'),
                          loading: () => const Center(child: CircularProgressIndicator()))),
                  const SongCard()
                ]))));
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          iconSize: 64.0,
          onPressed: player.stop,
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x", style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
