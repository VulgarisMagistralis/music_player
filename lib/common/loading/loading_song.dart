import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SongSkeleton extends StatelessWidget {
  const SongSkeleton({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
          child: Skeletonizer(
        key: key,
        ignoreContainers: true,
        enableSwitchAnimation: true,
        effect: ShimmerEffect(baseColor: Theme.of(context).colorScheme.primary, highlightColor: Theme.of(context).scaffoldBackgroundColor, duration: const Duration(seconds: 1)),
        child: const ListTile(title: Bone.text(words: 3), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Bone.icon(), SizedBox(width: 8), Bone.icon()])),
      ));
}
