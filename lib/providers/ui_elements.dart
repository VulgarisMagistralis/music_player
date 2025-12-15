import 'package:music_player/utilities/settings_data.dart' show SharedPreferenceWithCacheHandler;
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'ui_elements.g.dart';

/// Controls showing icons in the absence of album art of a song on list views
@Riverpod(keepAlive: true)
class ShowSongIcon extends _$ShowSongIcon {
  static const bool _defaultState = false;
  static const String _sharedPrefKey = 'behaviour.ui.show_song_icon';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

/// Controls for toggling Android OS navigation buttons
@Riverpod(keepAlive: true)
class ShowAndroidNavigationButtons extends _$ShowAndroidNavigationButtons {
  static const bool _defaultState = false;
  static const String _sharedPrefKey = 'behaviour.ui.android_nav_buttons';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    SystemChrome.setEnabledSystemUIMode(newValue ? SystemUiMode.edgeToEdge : SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class FontSizeAdjustment extends _$FontSizeAdjustment {
  static const int _minimum = 1;
  static const int _maximum = 5;
  static const int _defaultState = 3;
  static const String _sharedPrefKey = 'behaviour.ui.font_size_adjustment';
  @override
  int build() => SharedPreferenceWithCacheHandler.instance.loadInteger(_sharedPrefKey) ?? _defaultState;
  Future<void> update(int changeInValue) async {
    final int newValue = state + changeInValue;
    if (newValue < _minimum || newValue > _maximum) return;
    await SharedPreferenceWithCacheHandler.instance.saveInteger(_sharedPrefKey, newValue);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class IconSizeAdjustment extends _$IconSizeAdjustment {
  static const int _minimum = 1;
  static const int _maximum = 5;
  static const int _defaultState = 3;
  static const String _sharedPrefKey = 'behaviour.ui.icon_size_adjustment';
  @override
  int build() => SharedPreferenceWithCacheHandler.instance.loadInteger(_sharedPrefKey) ?? _defaultState;
  Future<void> update(int changeInValue) async {
    final int newValue = state + changeInValue;
    if (newValue < _minimum || newValue > _maximum) return;
    await SharedPreferenceWithCacheHandler.instance.saveInteger(_sharedPrefKey, newValue);
    state = newValue;
  }
}
