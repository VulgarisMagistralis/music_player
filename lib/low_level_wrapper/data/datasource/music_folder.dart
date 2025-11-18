import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/src/rust/api/music_folder.dart';
import 'package:music_player/src/rust/api/process_music.dart';

class LowLevelFolderDataSource {
  void setDirectory({required String path}) => setApplicationDataDirectory(path: path);

  void saveFolders({required List<String> folderList}) => saveMusicFolderList(folders: folderList);

  Future<List<String>> loadFolders() => getMusicFolderList();
  Future<List<Song>> readSongList() => readMusicFiles();
}
