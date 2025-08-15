import 'package:flutter/material.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/data/song.dart';
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
    final asyncAudioState = ref.watch(audioSessionManagerProvider);
    final manager = ref.read(audioSessionManagerProvider.notifier);
    return asyncAudioState.when(
      data: (AudioSessionState audioState) {
        if (!audioState.isReady) return const SizedBox.shrink();
        return Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (audioState.albumArt?.isNotEmpty ?? false) SizedBox(width: 35, height: 35, child: Image.memory(audioState.albumArt!, fit: BoxFit.cover)),
              const SizedBox(width: 8), // spacing between image and text
              Expanded(child: AnimatedOverflowText(text: manager.songName))
            ]),
            // AnimatedOverflowText(text: manager.songName),
            const ControlButtons(),
            Padding(
                padding: const EdgeInsets.all(5),
                child: StreamBuilder<PositionData>(
                  stream: manager.positionDataStream,
                  builder: (_, snapshot) => SeekBar(
                    onChangeEnd: manager.seek,
                    duration: snapshot.data?.duration ?? Duration.zero,
                    position: snapshot.data?.position ?? Duration.zero,
                    bufferedPosition: snapshot.data?.bufferedPosition ?? Duration.zero,
                  ),
                )),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
