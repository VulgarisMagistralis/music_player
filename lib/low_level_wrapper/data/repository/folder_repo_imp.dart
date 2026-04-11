import 'package:music_player/low_level_wrapper/data/datasource/music_folder.dart';
import 'package:music_player/low_level_wrapper/domain/repository/music_folder_imp.dart';

class LowLevelRepositoryImplementation implements FolderRepository {
  final LowLevelFolderDataSource dataSource = LowLevelFolderDataSource();
  LowLevelRepositoryImplementation();

  @override
  Future<void> setDirectory({required String applicationDirectory, required String cacheDirectory}) async => await dataSource.setDirectory(applicationDirectory: applicationDirectory, cacheDirectory: cacheDirectory);

  @override
  Future<List<String>> loadFolderList() async => await dataSource.loadFolders();

  @override
  Future<void> saveFolderList({required List<String> folderList}) async => await dataSource.saveFolders(folderList: folderList);
  @override
  Future<void> deleteFolder({required String folder}) async => await dataSource.deleteFolder(folder: folder);
}
