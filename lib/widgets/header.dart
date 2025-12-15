import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/sort_extensions.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart';

class PlayerHeader extends ConsumerStatefulWidget {
  final bool showExtraButtons;
  const PlayerHeader({super.key, this.showExtraButtons = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends ConsumerState<PlayerHeader> {
  bool _showFilterView = false;

  @override
  Widget build(BuildContext context) {
    final SortBy sortBy = ref.watch(playlistSortedByProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(ref.watch(playerRouteProvider).toTitle(), style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            if (widget.showExtraButtons)
              Row(
                children: [
                  const SizedBox(width: 10),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: GestureDetector(onTap: () => setState(() => _showFilterView = !_showFilterView), child: const Icon(Icons.sort)),
                  ),
                ],
              ),
          ],
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showFilterView
                ? Row(
                    children: [
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.timelapse), onPressed: () => ref.read(playlistSortedByProvider.notifier).update(sortBy.toggleDuration())),
                      IconButton(icon: const Icon(Icons.sort_by_alpha), onPressed: () => ref.read(playlistSortedByProvider.notifier).update(sortBy.toggleName())),
                      IconButton(icon: const Icon(Icons.date_range_outlined), onPressed: () => ref.read(playlistSortedByProvider.notifier).update(sortBy.toggleDate())),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
