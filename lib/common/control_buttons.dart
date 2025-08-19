import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlButtons extends ConsumerStatefulWidget {
  const ControlButtons({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlButtonState();
}

class _ControlButtonState extends ConsumerState<ControlButtons> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioSessionManagerProvider.notifier);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.skip_previous), iconSize: 32, onPressed: () async => player.hasPrevious ? await player.seekToPrevious() : null),
      StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (_, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return Container(margin: const EdgeInsets.all(8.0), width: 32, height: 32, child: const CircularProgressIndicator());
            } else if (playing != true) {
              return IconButton(icon: const Icon(Icons.play_arrow), iconSize: 32, onPressed: () async => await player.play());
            } else if (processingState != ProcessingState.completed) {
              return IconButton(icon: const Icon(Icons.pause), iconSize: 32, onPressed: () async => await player.pause());
            } else {
              return IconButton(icon: const Icon(Icons.replay), iconSize: 32, onPressed: () async => await player.seek(Duration.zero));
            }
          }),
      IconButton(icon: const Icon(Icons.stop), iconSize: 32, onPressed: () async => await player.stop()),
      IconButton(icon: const Icon(Icons.skip_next), iconSize: 32, onPressed: () async => player.hasNext ? await player.seekToNext() : null)
    ]);
  }
}
