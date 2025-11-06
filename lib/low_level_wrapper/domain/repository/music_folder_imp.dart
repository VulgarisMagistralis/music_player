abstract class FolderRepository {
  void setDirectory({required String applicationDirectory});
  void saveFolderList({required List<String> folderList});
  List<String> loadFolderList();
}
