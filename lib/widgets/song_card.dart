import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/position.dart';
import 'package:music_player/widgets/seek_bar.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/control_buttons.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/widgets/album_art_widget.dart';
import 'package:music_player/widgets/favourites_button.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/utilities/audio_session_manager.dart';

class NowPlaying extends ConsumerWidget {
  const NowPlaying({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final BigInt? songIdOrNull = ref.watch(audioSessionManagerProvider.select((s) => s.songId));
    final AsyncValue<Song?> currentSongOrNullAsync = ref.watch(getSongOrNullProvider(songId: songIdOrNull));
    return songIdOrNull == null
        ? const SizedBox.shrink(key: ValueKey('empty-now-playing'))
        : currentSongOrNullAsync.when(
            error: (_, __) => const SizedBox.shrink(key: ValueKey('empty-now-playing')),
            loading: () => const SizedBox.shrink(key: ValueKey('empty-now-playing')),
            data: (Song? songOrNull) => songOrNull == null
                ? const SizedBox.shrink(key: ValueKey('empty-now-playing'))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(),
                      Row(
                        children: [
                          AlbumArtWidget(songId: songOrNull.id, width: 60),
                          const SizedBox(width: 3),
                          Expanded(child: AnimatedOverflowText(text: songOrNull.title)),
                          FavouritesButton(songId: songOrNull.id),
                        ],
                      ),
                      StreamBuilder<PlayerState>(stream: audioHandler.playerStateStream, builder: (_, __) => const ControlButtons()),
                      Padding(
                        padding: const EdgeInsets.all(1),
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
                      const Divider(),
                    ],
                  ),
          );
  }
}
