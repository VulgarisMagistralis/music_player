import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:music_player/pages/loading_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/utilities/permission_provider.dart';
import 'package:music_player/pages/error_pages/permission_page.dart';
import 'package:music_player/pages/error_pages/generic_error_page.dart';

class AfterSplash extends ConsumerStatefulWidget {
  const AfterSplash({super.key});

  @override
  ConsumerState createState() => _AfterSplashState();
}

class _AfterSplashState extends ConsumerState<AfterSplash> {
  @override
  Widget build(BuildContext context) {
    final isReady = ref.watch(appReadyProvider);
    return ref
        .watch(permissionProvider)
        .when(
          data: (PermissionStatus status) {
            switch (status) {
              case PermissionStatus.granted:
                if (!isReady) return const LoadingPage();
                return const MusicPlayer();
              case PermissionStatus.denied:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(permissionProvider.notifier).requestPermission();
                });
                return const LoadingPage();
              default:
                return PermissionErrorPage();
            }
          },
          error: (_, __) => const GenericErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
