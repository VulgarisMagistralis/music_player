import 'package:music_player/src/rust/api/music_folder.dart';

class LowLevelFolderDataSource {
  void setDirectory({required String path}) =>
      setApplicationDataDirectory(path: path);

  void saveFolders({required List<String> folderList}) =>
      saveMusicFolderList(folders: folderList);

  List<String> loadFolders() => getMusicFolderList();
}
