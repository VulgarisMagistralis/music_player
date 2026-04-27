import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/utilities/thumbnail_uri.dart';
import 'package:music_player/src/rust/api/song_collection.dart';

class SongMediaItemFactory {
  static Future<MediaItem> fromSong(Song song) async {
    final path = (await getExternalCacheDirectories())?.first.path;
    final relativePath = await getSongAlbumArtFilePath(id: song.id);
    final artPath = '$path/$relativePath';
    return MediaItem(
      id: Uri.file(song.path).toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration != null ? Duration(seconds: song.duration!) : null,
      artUri: Uri.parse(getThumbnailUri(artPath)),
      extras: {'songId': song.id.toString()},
    );
  }

  static Future<List<MediaItem>> fromSongs(List<Song> songs) async {
    return await Future.wait(songs.map(fromSong).toList());
  }
}
