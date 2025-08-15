import 'package:flutter/material.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/header.dart';

/// Determine app state and reroute
/// check file read permission
class PlaylistPage extends ConsumerStatefulWidget {
  const PlaylistPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const PlayerNavigationBar(),
      body: Center(
          child: Container(
              padding: const EdgeInsets.all(30),
              child: const Column(children: [
                Row(
                  children: [
                    PlayerHeader(),
                  ],
                ),
              ]))));
}
