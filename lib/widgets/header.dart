import 'package:flutter/material.dart';
import 'package:music_player/route/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerHeader extends ConsumerStatefulWidget {
  const PlayerHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends ConsumerState<PlayerHeader> {
  @override
  Widget build(BuildContext context) => Expanded(
          child: Row(children: [
        Text(ref.watch(playerRouteProvider).toTitle()),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.replay_circle_filled)),
      ]));
}
