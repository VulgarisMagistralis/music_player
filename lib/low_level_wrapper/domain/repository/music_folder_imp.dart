abstract class FolderRepository {
  void setDirectory({required String applicationDirectory});
  void saveFolderList({required List<String> folderList});
  Future<List<String>> loadFolderList();
}
