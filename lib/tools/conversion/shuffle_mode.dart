import 'package:audio_service/audio_service.dart' show AudioServiceShuffleMode;
import 'package:flutter/material.dart';

extension AudioServiceShuffleModeExt on AudioServiceShuffleMode {
  String get androidIcon => switch (this) {
    AudioServiceShuffleMode.none => 'drawable/ic_shuffle',
    AudioServiceShuffleMode.group => 'drawable/ic_shuffle',
    AudioServiceShuffleMode.all => 'drawable/ic_shuffle_active',
  };
  IconData get appIcon => switch (this) {
    AudioServiceShuffleMode.none => Icons.shuffle,
    AudioServiceShuffleMode.group => Icons.shuffle,
    AudioServiceShuffleMode.all => Icons.shuffle_on_outlined,
  };
  String get label => switch (this) {
    AudioServiceShuffleMode.all => 'Shuffle all',
    AudioServiceShuffleMode.none => 'Shuffle off',
    AudioServiceShuffleMode.group => 'Shuffle off',
  };

  /// skip [AudioServiceShuffleMode.group] for now
  AudioServiceShuffleMode get next => switch (this) {
    AudioServiceShuffleMode.all => AudioServiceShuffleMode.none,
    AudioServiceShuffleMode.none => AudioServiceShuffleMode.all,
    _ => AudioServiceShuffleMode.none,
  };
}
