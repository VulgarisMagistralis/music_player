import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' show IconData;
import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:audio_service/audio_service.dart' show AudioServiceRepeatMode;

extension AudioServiceRepeatModeExt on AudioServiceRepeatMode {
  static const Map<AudioServiceRepeatMode, LoopMode> _toLoopMode = {
    AudioServiceRepeatMode.one: LoopMode.one,
    AudioServiceRepeatMode.all: LoopMode.all,
    AudioServiceRepeatMode.none: LoopMode.off,
    AudioServiceRepeatMode.group: LoopMode.all,
  };

  /// skips [AudioServiceRepeatMode.group] for now
  AudioServiceRepeatMode get next => switch (this) {
    AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
    AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
    AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
    _ => AudioServiceRepeatMode.none,
  };

  LoopMode toLoopMode() => _toLoopMode[this] ?? LoopMode.all;

  String get androidIcon => switch (this) {
    AudioServiceRepeatMode.none => 'drawable/ic_repeat',
    AudioServiceRepeatMode.group => 'drawable/ic_repeat',
    AudioServiceRepeatMode.all => 'drawable/ic_repeat_active',
    AudioServiceRepeatMode.one => 'drawable/ic_repeat_one_active',
  };
  IconData get appIcon => switch (this) {
    AudioServiceRepeatMode.none => Icons.repeat,
    AudioServiceRepeatMode.group => Icons.repeat,
    AudioServiceRepeatMode.all => Icons.repeat_on,
    AudioServiceRepeatMode.one => Icons.repeat_one_on_outlined,
  };
  String get label => switch (this) {
    AudioServiceRepeatMode.all => 'Repeat all',
    AudioServiceRepeatMode.one => 'Repeat one',
    AudioServiceRepeatMode.none => 'Repeat off',
    AudioServiceRepeatMode.group => 'Repeat all',
  };
}

extension LoopModeExt on LoopMode {
  static const Map<LoopMode, AudioServiceRepeatMode> _toAudioServiceRepeatMode = {LoopMode.off: AudioServiceRepeatMode.none, LoopMode.one: AudioServiceRepeatMode.one, LoopMode.all: AudioServiceRepeatMode.all};
  AudioServiceRepeatMode toAudioServiceRepeatMode() => _toAudioServiceRepeatMode[this] ?? AudioServiceRepeatMode.none;
  String get shuffleIcon => this == LoopMode.all ? 'drawable/ic_shuffle_active' : 'drawable/ic_shuffle';
  String get shuffleLabel => this == LoopMode.all ? 'Shuffle on' : 'Shuffle off';
}
