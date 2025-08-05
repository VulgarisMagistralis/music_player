import 'dart:async' show StreamController;
import 'package:music_player/utilities/string_extension.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'routes.g.dart';

/// add loading?
enum PlayerRouteEnum {
  songs,
  error,
  search,
  // startup,
  settings,
  playlists,
  favourites,
  permissions;

  String toTitle() => name.capitalize();
  String get path => switch (this) {
        PlayerRouteEnum.songs => '/$name',
        PlayerRouteEnum.error => '/$name',
        PlayerRouteEnum.search => '/$name',
        // PlayerRouteEnum.startup => '/$name',
        PlayerRouteEnum.settings => '/$name',
        PlayerRouteEnum.playlists => '/$name',
        PlayerRouteEnum.favourites => '/$name',
        PlayerRouteEnum.permissions => '/$name'
      };
}

@Riverpod(keepAlive: true)
class PlayerRoute extends _$PlayerRoute {
  final _controller = StreamController<PlayerRouteEnum>.broadcast();
  Stream<PlayerRouteEnum> get stream => _controller.stream;
  void resetRoute() => state = PlayerRouteEnum.songs;
  void updateRoute(PlayerRouteEnum newRoute) {
    state = newRoute;
    _controller.add(newRoute);
  }

  @override
  PlayerRouteEnum build() => PlayerRouteEnum.songs;
}
