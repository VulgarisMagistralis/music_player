import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/src/rust/api/data/playlist.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/widgets/album_art_widget.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/widgets/favourites_button.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/src/rust/api/data/song.dart' show Song;

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
  Timer? _longPressTimer;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AudioSessionState? audioState = ref.watch(audioSessionManagerProvider);
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
                    PopupMenuItem(
                      value: 1,
                      child: const Text('Add to playlist'),
                      onTap: () async {
                        final List<Playlist> playlists = await ref.read(playlistCollectionProvider.future);
                        if (context.mounted) {
                          showMenu(
                            context: context,
                            items: playlists
                                .map(
                                  (playlist) => PopupMenuItem(
                                    child: Text(playlist.name),
                                    onTap: () async {
                                      try {
                                        await ref.read(addSongToTargetPlaylistProvider(songId: widget.song.id, playlistId: playlist.id).future);
                                        ToastManager().showInfoToast('Added to ${playlist.name}');
                                      } catch (e) {
                                        ToastManager().showErrorToast('Failed to add song to ${playlist.name}');
                                      }
                                      ref.invalidate(playlistCollectionProvider);
                                    },
                                  ),
                                )
                                .toList(),
                            positionBuilder: (context, constraints) => RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
                          );
                        }
                      },
                    ),
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
                AlbumArtWidget(songId: widget.song.id, width: 50),
                const SizedBox(width: 10),
                Expanded(
                  child: audioState?.songId == widget.song.id
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.pink, BlendMode.srcIn),
                          child: AnimatedOverflowText(text: widget.song.title),
                        )
                      : AnimatedOverflowText(text: widget.song.title),
                ),
                FavouritesButton(songId: widget.song.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
