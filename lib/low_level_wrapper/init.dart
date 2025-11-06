import 'package:music_player/src/rust/frb_generated.dart';

class LowLevelInitializer {
  static bool _initialized = false;
  static Future<void> init() async {
    if (_initialized) return;
    await RustLib.init();
    _initialized = true;
  }
}
