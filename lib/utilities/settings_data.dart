import 'dart:convert';
import 'dart:ui' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/data/song.dart' show AudioSessionState;

/// ________ Keys  ________
const _libraryFolderListKey = 'library.folder.list';
const _lastSongStateKey = 'last.audio.session';

class SharedPreferenceWithCacheHandler {
  SharedPreferenceWithCacheHandler._internal();
  late final SharedPreferencesWithCache _sharedPreferences;
  static SharedPreferenceWithCacheHandler get instance => _instance;
  static final SharedPreferenceWithCacheHandler _instance = SharedPreferenceWithCacheHandler._internal();

  /// Call this once at app startup
  Future<void> init() async => _sharedPreferences = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());

  Future<void> saveMusicFolderList(List<String> updatedLibraryList) async => await _sharedPreferences.setStringList(_libraryFolderListKey, updatedLibraryList);

  List<String> getMusicFolderList() => _sharedPreferences.getStringList(_libraryFolderListKey) ?? [];

  Future<void> saveSongState(AudioSessionState state) async => await _sharedPreferences.setString(_lastSongStateKey, jsonEncode(state.toJson()));

  Future<AudioSessionState?> loadSongState() async {
    final String? storedStateSerialized = _sharedPreferences.getString(_lastSongStateKey);
    return storedStateSerialized == null ? null : AudioSessionState.fromJson(jsonDecode(storedStateSerialized));
  }

  // ____________ THEME ____________
  /// Color read/write
  Future<void> saveColor(String storageKey, int color32Bit) async => await _sharedPreferences.setInt(storageKey, color32Bit);
  Future<Color?> loadColor(String storageKey) async {
    int? storedColor = await _sharedPreferences.getInt(storageKey);
    return storedColor == null ? null : Color(storedColor);
  }
}
