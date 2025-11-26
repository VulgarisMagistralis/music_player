abstract class FolderRepository {
  void setDirectory({required String applicationDirectory});
  void saveFolderList({required List<String> folderList});
  void deleteFolder({required String folder});
  Future<List<String>> loadFolderList();
}
