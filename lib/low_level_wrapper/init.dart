import 'package:music_player/low_level_wrapper/data/datasource/music_folder.dart';
import 'package:music_player/low_level_wrapper/data/repository/folder_repo_imp.dart';
import 'package:music_player/src/rust/frb_generated.dart';
import 'package:path_provider/path_provider.dart';

class LowLevelInitializer {
  static bool _initialized = false;
  static Future<void> init() async {
    if (_initialized) return;
    await RustLib.init();
    // ignore: invalid_use_of_internal_member
    await RustLib.instance.api.crateApiUtilsLoggerInitRustLogger();
    final applicationDirectory = (await getApplicationSupportDirectory()).path;
    final cacheDirectory = (await getExternalCacheDirectories())?.first.path ?? applicationDirectory;
    await LowLevelRepositoryImplementation().setDirectory(cacheDirectory: cacheDirectory, applicationDirectory: applicationDirectory);
    try {
      final dataSource = LowLevelFolderDataSource();
      final folders = await dataSource.loadFolders();
      if (folders.isEmpty) {
        await dataSource.saveFolders(folderList: ['/storage/emulated/0/Music']);
      }
    } catch (_) {}
    _initialized = true;
  }
}
