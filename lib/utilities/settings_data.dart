import 'dart:ui' show Color;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/data/audio_session_state.dart' show AudioSessionState;

/// ________ Keys  ________
const _lastSongStateKey = 'audio.session.last_song';

class SharedPreferenceWithCacheHandler {
  SharedPreferenceWithCacheHandler._internal();
  late final SharedPreferencesWithCache _sharedPreferences;
  static SharedPreferenceWithCacheHandler get instance => _instance;
  static final SharedPreferenceWithCacheHandler _instance = SharedPreferenceWithCacheHandler._internal();

  /// Call this once at app startup
  Future<void> init() async => _sharedPreferences = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());

  Future<void> saveSongState(AudioSessionState state) async => await _sharedPreferences.setString(_lastSongStateKey, jsonEncode(state.toJson()));

  AudioSessionState? loadSongState() {
    final String? storedStateSerialized = _sharedPreferences.getString(_lastSongStateKey);
    print('LAODING STATE $storedStateSerialized');
    return storedStateSerialized == null ? null : AudioSessionState.fromJson(jsonDecode(storedStateSerialized));
  }

  Future<void> saveColor(String storageKey, int color32Bit) async => await _sharedPreferences.setInt(storageKey, color32Bit);
  Color? loadColor(String storageKey) {
    final int? storedColor = _sharedPreferences.getInt(storageKey);
    return storedColor == null ? null : Color(storedColor);
  }

  Future<void> saveBool(String key, bool flag) async => await _sharedPreferences.setBool(key, flag);
  bool? loadBool(String key) => _sharedPreferences.getBool(key);

  ///Technically duplicate
  Future<void> saveInteger(String key, int value) async => await _sharedPreferences.setInt(key, value);
  int? loadInteger(String key) => _sharedPreferences.getInt(key);
}
