// import 'dart:async';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:music_player/pages/error_page.dart';
// import 'package:music_player/pages/favourites.dart';
// import 'package:music_player/pages/playlists.dart';
// import 'package:music_player/pages/search.dart';
// import 'package:music_player/pages/settings.dart';
// import 'package:music_player/pages/songs.dart';
// import 'package:music_player/pages/startup.dart';
// import 'package:music_player/route/routes.dart';
// import 'package:permission_handler/permission_handler.dart';

// class GoRouterRefreshNotifier extends ChangeNotifier {
//   GoRouterRefreshNotifier(Stream<dynamic> stream) {
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
//   }

//   late final StreamSubscription _subscription;

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }

// final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((ref) {
//   final stream = ref.watch(playerRouteProvider.notifier).stream;
//   final notifier = GoRouterRefreshNotifier(stream);
//   ref.onDispose(() => notifier.dispose());
//   return notifier;
// });

// final goRouterProvider = Provider<GoRouter>((ref) {
//   final notifier = ref.watch(goRouterRefreshNotifierProvider);

//   return GoRouter(
//     debugLogDiagnostics: true,
//     initialLocation: PlayerRouteEnum.startup.path,
//     refreshListenable: notifier,
//     routes: [
//       GoRoute(path: PlayerRouteEnum.songs.path, pageBuilder: (_, __) => const NoTransitionPage(child: SongsPage())),
//       GoRoute(path: PlayerRouteEnum.error.path, pageBuilder: (_, __) => const NoTransitionPage(child: ErrorPage())),
//       GoRoute(path: PlayerRouteEnum.search.path, pageBuilder: (_, __) => const NoTransitionPage(child: SearchPage())),
//       GoRoute(path: PlayerRouteEnum.startup.path, pageBuilder: (_, __) => const NoTransitionPage(child: Startup())),
//       GoRoute(path: PlayerRouteEnum.settings.path, pageBuilder: (_, __) => const NoTransitionPage(child: SettingsPage())),
//       GoRoute(path: PlayerRouteEnum.playlists.path, pageBuilder: (_, __) => const NoTransitionPage(child: PlaylistPage())),
//       GoRoute(path: PlayerRouteEnum.favourites.path, pageBuilder: (_, __) => const NoTransitionPage(child: FavouritesPage())),
//     ],
//   );
// });
