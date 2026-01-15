import 'package:flutter/material.dart';
import 'dart:typed_data' show Uint8List;
import 'package:music_player/common/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/providers.dart' show songAlbumArtProvider;

class AlbumArtWidget extends ConsumerWidget {
  final double width;
  final BigInt songId;
  const AlbumArtWidget({super.key, required this.songId, required this.width});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(songAlbumArtProvider(songId: songId))
      .when(
        data: (Uint8List? albumArtOrNull) => SizedBox(
          width: width,
          height: width,
          child: albumArtOrNull == null ? Image.asset('assets/icons/note_2.png', fit: BoxFit.cover) : Image.memory(albumArtOrNull, cacheWidth: 50, cacheHeight: 50, fit: BoxFit.cover),
        ),
        error: (_, __) {
          ToastManager().showErrorToast('Couldn\'t fetch Album Art');
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
      );
}
