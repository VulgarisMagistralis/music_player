import 'package:music_player/low_level_wrapper/data/repository/folder_repo_imp.dart';
import 'package:music_player/src/rust/frb_generated.dart';
import 'package:path_provider/path_provider.dart';

class LowLevelInitializer {
  static bool _initialized = false;
  static Future<void> init() async {
    if (_initialized) return;
    await RustLib.init();
    _initialized = true;
    LowLevelRepositoryImplementation().setDirectory(applicationDirectory: (await getApplicationSupportDirectory()).path);
  }
}
