import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/pages/error_page.dart';
import 'package:music_player/pages/songs.dart';
import 'package:music_player/route/routes.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:permission_handler/permission_handler.dart';

class Startup extends ConsumerStatefulWidget {
  const Startup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StartupState();
}

class _StartupState extends ConsumerState<Startup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FutureBuilder(
        future: Permission.audio.request(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError || !(snapshot.data?.isGranted ?? false)) {
            ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.error);
            return ErrorPage();
          }
          ref.read(playerRouteProvider.notifier).updateRoute(PlayerRouteEnum.songs);

          return SongsPage();
        },
      )),
    );
  }
}
