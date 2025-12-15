import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/widgets/seek_bar.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/control_buttons.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/utilities/audio_session_manager.dart';

class SongCard extends ConsumerStatefulWidget {
  const SongCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard> {
  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.read(audioHandlerProvider);
    final AudioSessionState? audioState = ref.watch(audioSessionManagerProvider);
    return audioState == null
        ? const SizedBox.shrink()
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (audioState.albumArt?.isNotEmpty ?? false) SizedBox(width: 35, height: 35, child: Image.memory(audioState.albumArt!, fit: BoxFit.cover)),
                  const SizedBox(width: 8),
                  Expanded(child: AnimatedOverflowText(text: audioState.title ?? '')),
                ],
              ),
              StreamBuilder<PlayerState>(stream: audioHandler.playerStateStream, builder: (_, __) => const ControlButtons()),
              Padding(
                padding: const EdgeInsets.all(5),
                child: StreamBuilder<PositionData>(
                  stream: audioHandler.positionDataStream,
                  builder: (_, snapshot) => SeekBar(
                    onChangeEnd: audioHandler.seek,
                    duration: snapshot.data?.duration ?? Duration.zero,
                    position: snapshot.data?.position ?? Duration.zero,
                    bufferedPosition: snapshot.data?.bufferedPosition ?? Duration.zero,
                  ),
                ),
              ),
            ],
          );
  }
}
