import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:music_player/pages/loading_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget build(BuildContext context) => ref.watch(permissionProvider).when(
      data: (PermissionStatus status) {
        if (status == PermissionStatus.granted) {
          return const MusicPlayer();
        } else if (status == PermissionStatus.denied) {
          ref.read(permissionProvider.notifier).requestPermission();
          return PermissionErrorPage();
        }
        return PermissionErrorPage();
      },
      error: (error, stackTrace) => const GenericErrorPage(),
      loading: () => const LoadingPage());
}
