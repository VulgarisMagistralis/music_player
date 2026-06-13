import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/utilities/song_row.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/widgets/song_details_panel.dart';
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
  String placeholderPlaylistName = 'New Playlist Name';
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
    final isAutomotive = ref.watch(isAutomotiveOSProvider).value ?? false;
    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: OrientationBuilder(
        builder: (context, orientation) => LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isWidescreen = maxWidth > 900;
            return SafeArea(
              right: !isAutomotive,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
                child: isWidescreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                const PlayerHeader(showRescan: true),
                                const SizedBox(height: 10),
                                Expanded(child: _buildPlaylistContent(playlists)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Expanded(child: SongDetailsPanel()),
                                SizedBox(height: 10),
                                NowPlaying(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const PlayerHeader(showRescan: true),
                          Expanded(child: _buildPlaylistContent(playlists)),
                          _isKeyboardVisible ? const SizedBox.shrink() : const NowPlaying(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaylistContent(AsyncValue<List<Playlist>> playlists) {
    return switch (playlists) {
      AsyncError<List<Playlist>>() => Text(GeneratedLocalization.of(context).error_loading_library),
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
                          if (context.mounted) {
                            ToastManager().showInfoToast(GeneratedLocalization.of(context).toast_playlist_deleted(playlist.name));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastManager().showErrorToast(GeneratedLocalization.of(context).toast_add_to_playlist_failed(playlist.name));
                          }
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
                                  onTap: (int i) async => await ref.read(audioHandlerSyncProvider).setPlaylist('songs', songList, index: i),
                                ),
                              )
                              .toList(),
                          error: (_, _) {
                            ToastManager().showErrorToast(GeneratedLocalization.of(context).toast_load_songs_failed);
                            return [const SizedBox.shrink()];
                          },
                          loading: () => [const CircularProgressIndicator()],
                        ),
                  ),
                ),
                const Divider(),
                ExpansionTile(
                  title: Text(GeneratedLocalization.of(context).playlist_create_title),
                  children: [
                    Padding(
                      padding: const EdgeInsetsGeometry.only(right: 15),
                      child: TextField(
                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(hintText: placeholderPlaylistName),
                        onSubmitted: (newPlaylistName) async {
                          if (newPlaylistName.isEmpty) newPlaylistName = placeholderPlaylistName;
                          try {
                            await ref.read(addPlaylistProvider(newPlaylistName: newPlaylistName).future);
                            if (context.mounted) {
                              ToastManager().showInfoToast(GeneratedLocalization.of(context).toast_playlist_created(newPlaylistName));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ToastManager().showErrorToast(GeneratedLocalization.of(context).toast_playlist_create_failed(newPlaylistName));
                            }
                          }
                          ref.invalidate(playlistCollectionProvider);
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    };
  }
}
