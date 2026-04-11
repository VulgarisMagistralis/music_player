import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;

class FavouritesButton extends ConsumerWidget {
  final BigInt songId;
  const FavouritesButton({super.key, required this.songId});
  Future<void> _toggleFavourite(WidgetRef ref, bool isFavourite) async {
    if (isFavourite) {
      await ref.read(removeSongFromFavouritesPlaylistProvider(songId: songId).future);
    } else {
      await ref.read(addSongToFavouritesPlaylistProvider(songId: songId).future);
    }
    ref.invalidate(getFavouritesPlaylistProvider);
    ref.invalidate(isInFavouritesPlaylistProvider);
    ref.invalidate(favouriteSongsBootstrapProvider);
    ref.invalidate(getPlaylistSongsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(isInFavouritesPlaylistProvider(songId: songId))
      .when(
        data: (bool isFavourite) => isFavourite
            ? IconButton(icon: const Icon(Icons.favorite_sharp), onPressed: () async => _toggleFavourite(ref, isFavourite))
            : IconButton(icon: const Icon(Icons.favorite_border), onPressed: () async => _toggleFavourite(ref, isFavourite)),
        error: (_, __) {
          ToastManager().showErrorToast('Favourite status is unknown');
          return IconButton(icon: const Icon(Icons.favorite_border), onPressed: () async => _toggleFavourite(ref, false));
        },
        loading: () => const CircularProgressIndicator(),
      );
}
