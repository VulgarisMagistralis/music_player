import 'dart:convert';
import 'dart:ui' show Color;
import 'package:music_player/data/audio_session_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ________ Keys  ________
const _lastSongStateKey = 'last.audio.session';

class SharedPreferenceWithCacheHandler {
  SharedPreferenceWithCacheHandler._internal();
  late final SharedPreferencesWithCache _sharedPreferences;
  static SharedPreferenceWithCacheHandler get instance => _instance;
  static final SharedPreferenceWithCacheHandler _instance = SharedPreferenceWithCacheHandler._internal();

  /// Call this once at app startup
  Future<void> init() async => _sharedPreferences = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());

  ///TODO to rust
  Future<void> saveSongState(AudioSessionState state) async => await _sharedPreferences.setString(_lastSongStateKey, jsonEncode(state.toJson()));

  Future<AudioSessionState?> loadSongState() async {
    final String? storedStateSerialized = _sharedPreferences.getString(_lastSongStateKey);
    return storedStateSerialized == null ? null : AudioSessionState.fromJson(jsonDecode(storedStateSerialized));
  }

  // ____________ THEME ____________
  /// Color read/write
  Future<void> saveColor(String storageKey, int color32Bit) async => await _sharedPreferences.setInt(storageKey, color32Bit);
  Color? loadColor(String storageKey) {
    final int? storedColor = _sharedPreferences.getInt(storageKey);
    return storedColor == null ? null : Color(storedColor);
  }
}
