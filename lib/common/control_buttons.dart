import 'package:audio_service/audio_service.dart' show AudioProcessingState, AudioServiceRepeatMode, AudioServiceShuffleMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:music_player/tools/conversion/loop_mode_conversion.dart';
import 'package:music_player/tools/conversion/shuffle_mode.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/utilities/providers.dart';

class ControlButtons extends ConsumerStatefulWidget {
  const ControlButtons({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlButtonState();
}

class _ControlButtonState extends ConsumerState<ControlButtons> {
  Future<void> _shuffle(PlayerAudioHandler audioHandler) async {
    final AudioServiceShuffleMode nextMode = ref.read(shuffleModeProvider).next;
    await ref.read(shuffleModeProvider.notifier).setShuffleMode(nextMode);
    await audioHandler.setShuffleMode(nextMode);
    setState(() {});
  }

  Future<void> _repeat(PlayerAudioHandler audioHandler) async {
    final AudioServiceRepeatMode nextMode = ref.read(repeatModeProvider).next;
    await ref.read(repeatModeProvider.notifier).setRepeatMode(nextMode);
    await audioHandler.setRepeatMode(nextMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final PlayerAudioHandler audioHandler = ref.watch(audioHandlerSyncProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(ref.watch(repeatModeProvider).appIcon), onPressed: () async => await _repeat(audioHandler)),
        IconButton(icon: const Icon(Icons.fast_rewind), onPressed: () async => audioHandler.rewind()),
        IconButton(icon: const Icon(Icons.skip_previous), onPressed: () async => await audioHandler.skipToPrevious()),
        StreamBuilder(
          stream: audioHandler.playbackState,
          builder: (_, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
              return Container(margin: const EdgeInsets.all(8.0), width: 32, height: 32, child: const CircularProgressIndicator());
            } else if (playing != true) {
              return IconButton(icon: const Icon(Icons.play_arrow), onPressed: () async => await audioHandler.play());
            } else if (processingState != AudioProcessingState.completed) {
              return IconButton(icon: const Icon(Icons.pause), onPressed: () async => await audioHandler.pause());
            } else {
              return IconButton(icon: const Icon(Icons.replay), onPressed: () async => await audioHandler.seek(Duration.zero));
            }
          },
        ),
        IconButton(icon: const Icon(Icons.stop), onPressed: () async => await audioHandler.stop()),
        IconButton(icon: const Icon(Icons.skip_next), onPressed: () async => await audioHandler.skipToNext()),
        IconButton(icon: const Icon(Icons.fast_forward), onPressed: () async => await audioHandler.fastForward()),
        IconButton(icon: Icon(ref.watch(shuffleModeProvider).appIcon), onPressed: () async => await _shuffle(audioHandler)),
      ],
    );
  }
}
