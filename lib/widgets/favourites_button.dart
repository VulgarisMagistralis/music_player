import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;

class FavouritesButton extends ConsumerWidget {
  final BigInt songId;
  const FavouritesButton({super.key, required this.songId});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(isInFavouritesPlaylistProvider(songId: songId))
      .when(
        data: (bool isFavourite) => isFavourite
            ? IconButton(
                icon: const Icon(Icons.favorite_sharp),
                onPressed: () async {
                  await ref.read(removeSongFromFavouritesPlaylistProvider(songId: songId).future);
                  ref.invalidate(getFavouritesPlaylistProvider);
                  ref.invalidate(isInFavouritesPlaylistProvider);
                },
              )
            : IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () async {
                  await ref.read(addSongToFavouritesPlaylistProvider(songId: songId).future);
                  ref.invalidate(getFavouritesPlaylistProvider);
                  ref.invalidate(isInFavouritesPlaylistProvider);
                },
              ),
        error: (_, __) {
          ToastManager().showErrorToast('Favourite status is unknown');
          return IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () async {
              await ref.read(addSongToFavouritesPlaylistProvider(songId: songId).future);
              ref.invalidate(getFavouritesPlaylistProvider);
              ref.invalidate(isInFavouritesPlaylistProvider);
            },
          );
        },
        loading: () => const CircularProgressIndicator(),
      );
}
