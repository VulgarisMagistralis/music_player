import 'package:music_player/src/rust/api/music_folder.dart';
import 'package:music_player/src/rust/api/process_music.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';

class LowLevelFolderDataSource {
  Future<void> setDirectory({required String applicationDirectory, required String cacheDirectory}) async => await setAppDirectory(applicationDirectory: applicationDirectory, cacheDirectory: cacheDirectory);
  Future<void> saveFolders({required List<String> folderList}) async => await saveMusicFolderList(folders: folderList);
  Future<void> deleteFolder({required String folder}) async => await deleteMusicFolderList(folder: folder);
  Future<List<String>> loadFolders() => getMusicFolderList();
  Stream<StreamEvent> readSongList() => readMusicFiles();
}
