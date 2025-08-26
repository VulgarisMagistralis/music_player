import 'dart:async' show StreamController;
import 'package:music_player/utilities/string_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'routes.g.dart';

/// Extend playlist id per playlist created
enum PlayerPageEnum {
  songs,
  error,
  search,
  loading,
  settings,
  playlists,
  favourites;

  String toTitle() => name.capitalize();
  String get path => switch (this) {
        PlayerPageEnum.songs => '/$name',
        PlayerPageEnum.error => '/$name',
        PlayerPageEnum.search => '/$name',
        PlayerPageEnum.loading => '/$name',
        PlayerPageEnum.settings => '/$name',
        PlayerPageEnum.playlists => '/$name',
        PlayerPageEnum.favourites => '/$name',
      };
  String get playlistId => switch (this) {
        PlayerPageEnum.songs => name,
        PlayerPageEnum.playlists => '/$name',
        PlayerPageEnum.favourites => '/$name',
        _ => PlayerPageEnum.songs.name,
      };
}

@Riverpod(keepAlive: true)
class PlayerRoute extends _$PlayerRoute {
  final _controller = StreamController<PlayerPageEnum>.broadcast();
  Stream<PlayerPageEnum> get stream => _controller.stream;
  void resetRoute() => state = PlayerPageEnum.songs;
  void updateRoute(PlayerPageEnum newRoute) {
    state = newRoute;
    _controller.add(newRoute);
  }

  @override
  PlayerPageEnum build() => PlayerPageEnum.songs;
}
