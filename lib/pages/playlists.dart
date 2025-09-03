import 'package:flutter/material.dart';
import 'package:music_player/data/audio_session_state.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/widgets/header.dart';

/// Determine app state and reroute
/// check file read permission
class PlaylistPage extends ConsumerStatefulWidget {
  final String? playlistId;
  const PlaylistPage({super.key, this.playlistId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    AudioSessionState? audioSessionState = ref.watch(audioSessionManagerProvider).value;
    return Scaffold(
        bottomNavigationBar: const PlayerNavigationBar(),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            children: [
              PlayerHeader(),
              if (audioSessionState?.playlistId == null) Text('Playlists:')

              /// if playlist id open it otherwise list all
            ],
          ),
        )));
  }
}
