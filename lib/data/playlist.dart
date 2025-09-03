import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart' show Uuid;
part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({required String id, @Default('Playlist') String name, @Default([]) List<String> songIdList}) = _Playlist;
  factory Playlist.create({required String id, @Default('Playlist') required String name, @Default([]) required List<String> songIdList}) => Playlist(name: name, id: const Uuid().v4(), songIdList: songIdList);

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);

// todo add sort, metadata ops,
}
