import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/pages/loading_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/theme/theme_providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/pages/error_pages/permission_page.dart';

class AfterSplash extends ConsumerStatefulWidget {
  const AfterSplash({super.key});

  @override
  ConsumerState createState() => _AfterSplashState();
}

class _AfterSplashState extends ConsumerState<AfterSplash> {
  Future<PermissionStatus> init() async {
    await ref.read(playerThemeProvider.notifier).loadStoredThemeData();
    if (!(await Permission.audio.isGranted)) {
      ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.error);
    } else {
      ///todo update from saved session state
      ///todo check if there are any favs
      ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.songs);
    }
    return Permission.audio.request();
  }

  /// without app starting-> connecting to Android auto stuck at loading?
  /// lost seekbar on notification status screen
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoadingPage();
        if (!(snapshot.data?.isGranted ?? false)) return PermissionErrorPage();
        if (snapshot.hasError) ref.read(playerRouteProvider.notifier).updateRoute(PlayerPageEnum.error);
        return const MusicPlayer();
      });
}
