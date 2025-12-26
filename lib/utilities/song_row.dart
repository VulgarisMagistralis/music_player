import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/src/rust/api/data/song.dart' show Song;
import 'package:music_player/utilities/providers.dart' show albumArtProvider;

class SongRow extends ConsumerStatefulWidget {
  final Song song;
  final int index;
  final void Function(int index) onTap;

  const SongRow({super.key, required this.song, required this.index, required this.onTap});

  @override
  ConsumerState<SongRow> createState() => _SongRowState();
}

class _SongRowState extends ConsumerState<SongRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bytes = ref.watch(albumArtProvider(widget.song.id).select((value) => value.value));
    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 50, height: 50, child: bytes != null ? Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true, cacheWidth: 50, cacheHeight: 50) : Image.asset('assets/icons/note_2.png', width: 50)),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(widget.index),
                  child: AnimatedOverflowText(text: widget.song.title),
                ),
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
        ],
      ),
    );
  }
}
