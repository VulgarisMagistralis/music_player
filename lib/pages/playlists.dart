import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/utilities/song_row.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/loading_animation.dart';
import 'package:music_player/src/rust/api/data/playlist.dart';

/// Determine app state and reroute
/// check file read permission
class PlaylistPage extends ConsumerStatefulWidget {
  final String? playlistId;
  const PlaylistPage({super.key, this.playlistId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> with WidgetsBindingObserver {
  String placeholderPlaylistName = 'New Playlist';
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final double bottomInset = View.of(context).viewInsets.bottom;
    setState(() => _isKeyboardVisible = bottomInset > 0);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Playlist>> playlists = ref.watch(playlistCollectionProvider);
    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            children: [
              const PlayerHeader(),
              Expanded(
                child: switch (playlists) {
                  AsyncError<List<Playlist>>() => const Text('Failed!!!'),
                  AsyncLoading<List<Playlist>>() => const WaveformLoading(),
                  AsyncData<List<Playlist>>() => Column(
                    children: [
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ...playlists.requireValue.map(
                              (playlist) => ExpansionTile(
                                title: Row(children: [Text(playlist.name)]),
                                trailing: GestureDetector(
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    shadows: [Shadow(blurRadius: 4, offset: Offset(1, 1))],
                                    color: Colors.red,
                                  ),
                                  onTap: () async {
                                    try {
                                      await ref.read(deletePlaylistFromCollectionProvider(playlistId: playlist.id).future);
                                      ToastManager().showInfoToast('Deleted ${playlist.name}');
                                    } catch (e) {
                                      ToastManager().showErrorToast('Failed to delete ${playlist.name}');
                                    }
                                    ref.invalidate(playlistCollectionProvider);
                                  },
                                ),
                                children: ref
                                    .watch(getPlaylistSongsProvider(playlist: playlist))
                                    .when(
                                      data: (songList) => songList
                                          .asMap()
                                          .entries
                                          .map(
                                            (songMap) => SongRow(
                                              song: songMap.value,
                                              index: songMap.key,
                                              onTap: (int i) async => await ref.read(audioHandlerProvider).setPlaylist('songs', songList, index: i),
                                            ),
                                          )
                                          .toList(),
                                      error: (_, __) {
                                        ToastManager().showErrorToast('Failed to load songs');
                                        return [const SizedBox.shrink()];
                                      },
                                      loading: () => [const CircularProgressIndicator()],
                                    ),
                              ),
                            ),
                            const Divider(),
                            ExpansionTile(
                              title: const Text('Create Playlist'),
                              children: [
                                TextField(
                                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                  decoration: InputDecoration(border: const OutlineInputBorder(), hintText: placeholderPlaylistName),
                                  onSubmitted: (newPlaylistName) async {
                                    if (newPlaylistName.isEmpty) return;
                                    try {
                                      await ref.read(addPlaylistProvider(newPlaylistName: newPlaylistName).future);
                                      ToastManager().showInfoToast('Created $newPlaylistName');
                                    } catch (e) {
                                      ToastManager().showErrorToast('Failed to create $newPlaylistName');
                                    }
                                    ref.invalidate(playlistCollectionProvider);
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                },
              ),
              _isKeyboardVisible ? const SizedBox.shrink() : const SongCard(),

              /// if playlist id open it otherwise list all
            ],
          ),
        ),
      ),
    );
  }
}
