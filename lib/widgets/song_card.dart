import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/song.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/pages/error_page.dart';
import 'package:music_player/widgets/seek_bar.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_card.dart';
import 'package:music_player/common/control_buttons.dart';

class SongCard extends ConsumerStatefulWidget {
  const SongCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard> {
  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.read(audioHandlerProvider);
    return ref.watch(audioSessionManagerProvider).when(
        data: (AudioSessionState? audioState) {
          if (audioState == null || !audioState.isReady) return const SizedBox.shrink();
          return Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (audioState.albumArt?.isNotEmpty ?? false) SizedBox(width: 35, height: 35, child: Image.memory(audioState.albumArt!, fit: BoxFit.cover)),
              const SizedBox(width: 8),
              Expanded(child: AnimatedOverflowText(text: audioState.title ?? ''))
            ]),
            StreamBuilder<PlayerState>(stream: audioHandler.playerStateStream, builder: (_, __) => const ControlButtons()),
            Padding(
                padding: const EdgeInsets.all(5),
                child: StreamBuilder<PositionData>(
                    stream: audioHandler.positionDataStream,
                    builder: (_, snapshot) => SeekBar(
                        onChangeEnd: audioHandler.seek,
                        duration: snapshot.data?.duration ?? Duration.zero,
                        position: snapshot.data?.position ?? Duration.zero,
                        bufferedPosition: snapshot.data?.bufferedPosition ?? Duration.zero)))
          ]);
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => ErrorPage(message: err.toString()));
  }
}
