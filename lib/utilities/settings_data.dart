import 'package:shared_preferences/shared_preferences.dart';

/// ________ Keys  ________
const _libraryFolderListKey = 'library.folder.list';

class SharedPreferenceWithCacheHandler {
  SharedPreferenceWithCacheHandler._internal();
  late final SharedPreferencesWithCache _sharedPreferences;
  static SharedPreferenceWithCacheHandler get instance => _instance;
  static final SharedPreferenceWithCacheHandler _instance = SharedPreferenceWithCacheHandler._internal();

  /// Call this once at app startup
  Future<void> init() async => _sharedPreferences = await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {
        _libraryFolderListKey,
      }));

  Future<void> saveMusicFolderList(List<String> updatedLibraryList) async => await _sharedPreferences.setStringList(_libraryFolderListKey, updatedLibraryList);

  List<String> getMusicFolderList() => _sharedPreferences.getStringList(_libraryFolderListKey) ?? [];
}
