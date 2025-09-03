import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/data/sort_options.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerHeader extends ConsumerStatefulWidget {
  final bool showExtraButtons;
  const PlayerHeader({super.key, this.showExtraButtons = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends ConsumerState<PlayerHeader> {
  bool showFilterView = false;
  void _iconButtonToggle(SortBy sortBy) {
    final SortBy newSortBy = sortBy.toggleName();
    ToastManager().showInfoToast('Sorted by $newSortBy');
    ref.read(playlistSortedByProvider.notifier).update(newSortBy);
  }

  @override
  Widget build(BuildContext context) {
    final SortBy sortBy = ref.watch(playlistSortedByProvider);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(ref.watch(playerRouteProvider).toTitle(), style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
        if (widget.showExtraButtons)
          Row(children: [
            // GestureDetector(onTap: () => ref.invalidate(readSongFileListProvider), child: const Icon(Icons.replay_circle_filled)),
            const SizedBox(width: 10),
            Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: GestureDetector(onTap: () => setState(() => showFilterView = !showFilterView), child: const Icon(Icons.sort)))
          ])
      ]),
      ClipRect(
          child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: showFilterView
                  ? Row(children: [
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.timelapse), onPressed: () => _iconButtonToggle(sortBy)),
                      IconButton(icon: const Icon(Icons.sort_by_alpha), onPressed: () => _iconButtonToggle(sortBy)),
                      IconButton(icon: const Icon(Icons.date_range_outlined), onPressed: () => _iconButtonToggle(sortBy))
                    ])
                  : const SizedBox.shrink()))
    ]);
  }
}
