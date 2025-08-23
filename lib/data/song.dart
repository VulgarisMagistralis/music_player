import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:music_player/utilities/media_item_converter.dart';
import 'package:music_player/utilities/uint8_list_base64_converter.dart';
import 'package:music_player/utilities/file_system_entity_converter.dart';
part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class AudioSessionState with _$AudioSessionState {
  const factory AudioSessionState([
    @Default('songs') String playlistId,
    @FileSystemEntityConverter() FileSystemEntity? file,
    String? title,
    @Default(0) int songIndexInPlaylist,
    @Default(false) bool isPlaying,
    @Default(false) bool isReady,
    @Uint8ListBase64Converter() Uint8List? albumArt,
    @MediaItemConverter() MediaItem? asMediaItem,
  ]) = _AudioSessionState;
  factory AudioSessionState.initial() => const AudioSessionState();
  factory AudioSessionState.fromJson(Map<String, dynamic> json) => _$AudioSessionStateFromJson(json);
}
