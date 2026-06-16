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
        final musicPath = await _getMusicDirectory();
        await dataSource.saveFolders(folderList: [musicPath]);
      }
    } catch (_) {}
    _initialized = true;
  }

  static Future<String> _getMusicDirectory() async {
    try {
      final cacheDir = (await getExternalCacheDirectories())?.first.path;
      if (cacheDir != null) {
        final parts = cacheDir.split('/');
        final emulatedIndex = parts.indexOf('emulated');
        if (emulatedIndex >= 0 && emulatedIndex + 2 < parts.length) {
          final userRoot = '/${parts.sublist(1, emulatedIndex + 2).join('/')}';
          return '$userRoot/Music';
        }
      }
    } catch (_) {}
    return '/storage/emulated/0/Music';
  }
}
