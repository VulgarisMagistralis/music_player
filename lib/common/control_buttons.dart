import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
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
    final audioHandler = ref.watch(audioHandlerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.skip_previous), iconSize: 32, onPressed: () async => await audioHandler.skipToPrevious()),
        StreamBuilder(
          stream: audioHandler.playbackState,
          builder: (_, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
              return Container(margin: const EdgeInsets.all(8.0), width: 32, height: 32, child: const CircularProgressIndicator());
            } else if (playing != true) {
              return IconButton(icon: const Icon(Icons.play_arrow), iconSize: 32, onPressed: () async => await audioHandler.play());
            } else if (processingState != AudioProcessingState.completed) {
              return IconButton(icon: const Icon(Icons.pause), iconSize: 32, onPressed: () async => await audioHandler.pause());
            } else {
              return IconButton(icon: const Icon(Icons.replay), iconSize: 32, onPressed: () async => await audioHandler.seek(Duration.zero));
            }
          },
        ),
        IconButton(icon: const Icon(Icons.stop), iconSize: 32, onPressed: () async => await audioHandler.stop()),
        IconButton(icon: const Icon(Icons.skip_next), iconSize: 32, onPressed: () async => audioHandler.skipToNext()),
      ],
    );
  }
}
