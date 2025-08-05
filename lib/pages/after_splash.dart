import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/music_player.dart';
import 'package:music_player/route/routes.dart';
import 'package:permission_handler/permission_handler.dart';

class AfterSplash extends ConsumerStatefulWidget {
  const AfterSplash({super.key});

  @override
  ConsumerState createState() => _AfterSplashState();
}

class _AfterSplashState extends ConsumerState<AfterSplash> {
  Future<PermissionStatus> init() async {
    /// load last played
    return Permission.audio.request();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (snapshot.hasError) ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.error);
        return const MusicPlayer();
      },
    );
  }
}
