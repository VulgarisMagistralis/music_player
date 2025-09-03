import 'dart:io';
import 'package:uuid/uuid.dart' show Uuid;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basenameWithoutExtension;
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:music_player/utilities/file_system_entity_converter.dart';
part 'song.freezed.dart';
part 'song.g.dart';

// TODO persist
@freezed
abstract class Song with _$Song {
  const factory Song({
    /// UUID
    ///
    /// Automatically to v4
    required String id,

    /// Title for the song, can be pulled from metadata as well
    String? title,
    String? album,
    String? artist,
    DateTime? modified,
    int? durationInMilliseconds,
    @Default(false) bool isInFavourites,
    @FileSystemEntityConverter() FileSystemEntity? file,
  }) = _Song;

  factory Song.create({@FileSystemEntityConverter() required File file, String? title, int? durationInMilliseconds, DateTime? modified}) =>
      Song(id: const Uuid().v4(), file: file, title: basenameWithoutExtension(file.path));

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  factory Song.toggleFavourite(Song oldSong) => oldSong.copyWith(isInFavourites: !oldSong.isInFavourites);

  // TODO with isolate
  static Future<Song> fillMetadataFromFile(File file) async {
    final AudioMetadata audioMetadata = readMetadata(file);
    return Song(id: const Uuid().v4(), file: file, album: audioMetadata.album, artist: audioMetadata.artist, modified: file.lastModifiedSync(), durationInMilliseconds: audioMetadata.duration?.inMilliseconds);
  }
}
