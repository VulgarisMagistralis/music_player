import 'package:audio_service/audio_service.dart' show AudioServiceShuffleMode, AudioServiceRepeatMode;
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
  static const int _minimum = -5;
  static const int _maximum = 5;
  static const int _defaultState = 0;
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
  static const int _minimum = -5;
  static const int _maximum = 5;
  static const int _defaultState = 0;
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

@Riverpod(keepAlive: true)
class ShuffleModeNotifier extends _$ShuffleModeNotifier {
  static const AudioServiceShuffleMode _defaultState = AudioServiceShuffleMode.none;
  static const String _sharedPrefKey = 'behaviour.playback.shuffle_mode';

  @override
  AudioServiceShuffleMode build() {
    final String? savedValue = SharedPreferenceWithCacheHandler.instance.loadString(_sharedPrefKey);
    if (savedValue == null) return _defaultState;
    return AudioServiceShuffleMode.values.firstWhere((mode) => mode.name == savedValue);
  }

  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await SharedPreferenceWithCacheHandler.instance.saveString(_sharedPrefKey, shuffleMode.name);
    state = shuffleMode;
  }
}

@Riverpod(keepAlive: true)
class RepeatModeNotifier extends _$RepeatModeNotifier {
  static const AudioServiceRepeatMode _defaultState = AudioServiceRepeatMode.none;
  static const String _sharedPrefKey = 'behaviour.playback.repeat_mode';

  @override
  AudioServiceRepeatMode build() {
    final String? savedValue = SharedPreferenceWithCacheHandler.instance.loadString(_sharedPrefKey);
    if (savedValue == null) return _defaultState;
    return AudioServiceRepeatMode.values.firstWhere((mode) => mode.name == savedValue, orElse: () => _defaultState);
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    await SharedPreferenceWithCacheHandler.instance.saveString(_sharedPrefKey, mode.name);
    state = mode;
  }
}
