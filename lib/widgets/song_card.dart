import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/providers.dart';

class SongCard extends ConsumerStatefulWidget {
  const SongCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard> {
  @override
  Widget build(BuildContext context) {
    final title = ref.watch(getSongTitle);
    return title.isEmpty ? const SizedBox.shrink() : Flexible(child: ListTile(leading: const Icon(Icons.play_arrow), title: Text(title)));
  }
}
