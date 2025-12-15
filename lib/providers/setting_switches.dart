import 'package:music_player/utilities/settings_data.dart' show SharedPreferenceWithCacheHandler;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'setting_switches.g.dart';

@Riverpod(keepAlive: true)
class PlayOnLaunch extends _$PlayOnLaunch {
  static const bool _defaultState = true;
  static const String _sharedPrefKey = 'behaviour.flag.play_on_launch';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class PlayOnConnect extends _$PlayOnConnect {
  static const bool _defaultState = true;
  static const String _sharedPrefKey = 'behaviour.flag.play_on_connect';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

///? USEFUL?
@Riverpod(keepAlive: true)
class PauseOnHidden extends _$PauseOnHidden {
  static const bool _defaultState = false;
  static const String _sharedPrefKey = 'behaviour.flag.pause_on_hidden';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class PauseWhenMuted extends _$PauseWhenMuted {
  static const bool _defaultState = false;
  static const String _sharedPrefKey = 'behaviour.flag.pause_when_muted';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class ResumeAfterDisconnect extends _$ResumeAfterDisconnect {
  static const bool _defaultState = false;
  static const String _sharedPrefKey = 'behaviour.flag.resume_after_disconnect';
  @override
  bool build() => SharedPreferenceWithCacheHandler.instance.loadBool(_sharedPrefKey) ?? _defaultState;
  Future<void> setFlag(bool newValue) async {
    await SharedPreferenceWithCacheHandler.instance.saveBool(_sharedPrefKey, newValue);
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class RewindIntervalInSeconds extends _$RewindIntervalInSeconds {
  static const int _minimum = 1;
  static const int _maximum = 10;
  static const int _defaultState = 3;
  static const String _sharedPrefKey = 'behaviour.playback.rewind_interval_in_seconds';
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
class FastForwardIntervalInSeconds extends _$FastForwardIntervalInSeconds {
  static const int _minimum = 1;
  static const int _maximum = 10;
  static const int _defaultState = 3;
  static const String _sharedPrefKey = 'behaviour.playback.fast_forward_interval_in_seconds';
  @override
  int build() => SharedPreferenceWithCacheHandler.instance.loadInteger(_sharedPrefKey) ?? _defaultState;
  Future<void> update(int changeInValue) async {
    final int newValue = state + changeInValue;
    if (newValue < _minimum || newValue > _maximum) return;
    await SharedPreferenceWithCacheHandler.instance.saveInteger(_sharedPrefKey, newValue);
    state = newValue;
  }
}
