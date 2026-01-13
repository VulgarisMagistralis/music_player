import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/src/rust/api/data/song.dart' show Song;
import 'package:music_player/utilities/providers.dart' show albumArtProvider;

class SongRow extends ConsumerStatefulWidget {
  final Song song;
  final int index;
  final bool isCompact;
  final void Function(int index) onTap;
  const SongRow({super.key, required this.song, required this.index, required this.onTap, this.isCompact = false});

  @override
  ConsumerState<SongRow> createState() => _SongRowState();
}

class _SongRowState extends ConsumerState<SongRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Timer? _longPressTimer;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AudioSessionState? audioState = ref.watch(audioSessionManagerProvider);
    final bytes = ref.watch(albumArtProvider(widget.song.id).select((value) => value.value));
    return SizedBox(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(widget.index),
            onTapDown: (details) {
              _longPressTimer = Timer(const Duration(milliseconds: 200), () async {
                final position = details.globalPosition;

                /// TODO
                showMenu(
                  positionBuilder: (context, constraints) => RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
                  context: context,
                  items: [
                    const PopupMenuItem(value: 1, child: Text('Add to playlist')),
                    const PopupMenuItem(value: 2, child: Text('Ignore song')),
                    const PopupMenuItem(value: 3, child: Text('Details')),
                  ],
                );
              });
            },
            onTapUp: (_) => _longPressTimer?.cancel(),
            onTapCancel: () => _longPressTimer?.cancel(),
            child: Row(
              children: [
                SizedBox(width: 50, height: 50, child: bytes != null ? Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true, cacheWidth: 50, cacheHeight: 50) : Image.asset('assets/icons/note_2.png', width: 50)),
                const SizedBox(width: 10),
                Expanded(
                  child: audioState?.songId == widget.song.id
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.pink, BlendMode.srcIn),
                          child: AnimatedOverflowText(text: widget.song.title),
                        )
                      : AnimatedOverflowText(text: widget.song.title),
                ),
                IconButton(
                  icon: const Icon(
                    false
                        // songList[index].isInFavourites
                        ? Icons.favorite_sharp
                        : Icons.favorite_border,
                  ),
                  onPressed: () => setState(
                    () => null, // songList[index] =
                    //     Song.toggleFavourite(
                    //         songList[index])
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
