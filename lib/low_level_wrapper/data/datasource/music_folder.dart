import 'package:music_player/src/rust/api/music_folder.dart';
import 'package:music_player/src/rust/api/process_music.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';

class LowLevelFolderDataSource {
  void setDirectory({required String path}) => setAppDirectory(path: path);
  Future<void> saveFolders({required List<String> folderList}) async => await saveMusicFolderList(folders: folderList);
  Future<void> deleteFolder({required String folder}) async => await deleteMusicFolderList(folder: folder);
  Future<List<String>> loadFolders() => getMusicFolderList();
  Stream<StreamEvent> readSongList() => readMusicFiles();
}
