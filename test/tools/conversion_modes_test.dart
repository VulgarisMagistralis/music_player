import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/tools/conversion/loop_mode_conversion.dart';
import 'package:music_player/tools/conversion/shuffle_mode.dart';

void main() {
  group('AudioServiceRepeatModeExt', () {
    group('toLoopMode', () {
      test('maps none to LoopMode.off', () {
        expect(AudioServiceRepeatMode.none.toLoopMode(), LoopMode.off);
      });

      test('maps one to LoopMode.one', () {
        expect(AudioServiceRepeatMode.one.toLoopMode(), LoopMode.one);
      });

      test('maps all to LoopMode.all', () {
        expect(AudioServiceRepeatMode.all.toLoopMode(), LoopMode.all);
      });

      test('maps group to LoopMode.all', () {
        expect(AudioServiceRepeatMode.group.toLoopMode(), LoopMode.all);
      });
    });

    group('next', () {
      test('cycles none -> all', () {
        expect(AudioServiceRepeatMode.none.next, AudioServiceRepeatMode.all);
      });

      test('cycles all -> one', () {
        expect(AudioServiceRepeatMode.all.next, AudioServiceRepeatMode.one);
      });

      test('cycles one -> none', () {
        expect(AudioServiceRepeatMode.one.next, AudioServiceRepeatMode.none);
      });

      test('group falls through to none', () {
        expect(AudioServiceRepeatMode.group.next, AudioServiceRepeatMode.none);
      });

      test('full cycle returns to start', () {
        var mode = AudioServiceRepeatMode.none;
        mode = mode.next;
        mode = mode.next;
        mode = mode.next;
        expect(mode, AudioServiceRepeatMode.none);
      });
    });

    group('androidIcon', () {
      test('none returns ic_repeat', () {
        expect(AudioServiceRepeatMode.none.androidIcon, 'drawable/ic_repeat');
      });

      test('all returns ic_repeat_active', () {
        expect(AudioServiceRepeatMode.all.androidIcon, 'drawable/ic_repeat_active');
      });

      test('one returns ic_repeat_one_active', () {
        expect(AudioServiceRepeatMode.one.androidIcon, 'drawable/ic_repeat_one_active');
      });

      test('group returns ic_repeat', () {
        expect(AudioServiceRepeatMode.group.androidIcon, 'drawable/ic_repeat');
      });
    });

    group('appIcon', () {
      test('none returns Icons.repeat', () {
        expect(AudioServiceRepeatMode.none.appIcon, Icons.repeat);
      });

      test('all returns Icons.repeat_on', () {
        expect(AudioServiceRepeatMode.all.appIcon, Icons.repeat_on);
      });

      test('one returns Icons.repeat_one_on_outlined', () {
        expect(AudioServiceRepeatMode.one.appIcon, Icons.repeat_one_on_outlined);
      });

      test('group returns Icons.repeat', () {
        expect(AudioServiceRepeatMode.group.appIcon, Icons.repeat);
      });
    });

    group('label', () {
      test('none returns Repeat off', () {
        expect(AudioServiceRepeatMode.none.label, 'Repeat off');
      });

      test('all returns Repeat all', () {
        expect(AudioServiceRepeatMode.all.label, 'Repeat all');
      });

      test('one returns Repeat one', () {
        expect(AudioServiceRepeatMode.one.label, 'Repeat one');
      });

      test('group returns Repeat all', () {
        expect(AudioServiceRepeatMode.group.label, 'Repeat all');
      });
    });
  });

  group('LoopModeExt', () {
    group('toAudioServiceRepeatMode', () {
      test('maps off to none', () {
        expect(LoopMode.off.toAudioServiceRepeatMode(), AudioServiceRepeatMode.none);
      });

      test('maps one to one', () {
        expect(LoopMode.one.toAudioServiceRepeatMode(), AudioServiceRepeatMode.one);
      });

      test('maps all to all', () {
        expect(LoopMode.all.toAudioServiceRepeatMode(), AudioServiceRepeatMode.all);
      });
    });

    group('shuffleIcon', () {
      test('all returns active icon', () {
        expect(LoopMode.all.shuffleIcon, 'drawable/ic_shuffle_active');
      });

      test('off returns default icon', () {
        expect(LoopMode.off.shuffleIcon, 'drawable/ic_shuffle');
      });

      test('one returns default icon', () {
        expect(LoopMode.one.shuffleIcon, 'drawable/ic_shuffle');
      });
    });

    group('shuffleLabel', () {
      test('all returns on label', () {
        expect(LoopMode.all.shuffleLabel, 'Shuffle on');
      });

      test('off returns off label', () {
        expect(LoopMode.off.shuffleLabel, 'Shuffle off');
      });

      test('one returns off label', () {
        expect(LoopMode.one.shuffleLabel, 'Shuffle off');
      });
    });
  });

  group('round-trip conversions', () {
    test('RepeatMode -> LoopMode -> RepeatMode preserves value', () {
      for (final mode in [AudioServiceRepeatMode.none, AudioServiceRepeatMode.one, AudioServiceRepeatMode.all]) {
        final loopMode = mode.toLoopMode();
        final back = loopMode.toAudioServiceRepeatMode();
        expect(back, mode, reason: '$mode -> $loopMode -> $back');
      }
    });
  });

  group('AudioServiceShuffleModeExt', () {
    group('androidIcon', () {
      test('none returns ic_shuffle', () {
        expect(AudioServiceShuffleMode.none.androidIcon, 'drawable/ic_shuffle');
      });

      test('all returns ic_shuffle_active', () {
        expect(AudioServiceShuffleMode.all.androidIcon, 'drawable/ic_shuffle_active');
      });

      test('group returns ic_shuffle', () {
        expect(AudioServiceShuffleMode.group.androidIcon, 'drawable/ic_shuffle');
      });
    });

    group('appIcon', () {
      test('none returns Icons.shuffle', () {
        expect(AudioServiceShuffleMode.none.appIcon, Icons.shuffle);
      });

      test('all returns Icons.shuffle_on_outlined', () {
        expect(AudioServiceShuffleMode.all.appIcon, Icons.shuffle_on_outlined);
      });

      test('group returns Icons.shuffle', () {
        expect(AudioServiceShuffleMode.group.appIcon, Icons.shuffle);
      });
    });

    group('label', () {
      test('all returns Shuffle all', () {
        expect(AudioServiceShuffleMode.all.label, 'Shuffle all');
      });

      test('none returns Shuffle off', () {
        expect(AudioServiceShuffleMode.none.label, 'Shuffle off');
      });

      test('group returns Shuffle off', () {
        expect(AudioServiceShuffleMode.group.label, 'Shuffle off');
      });
    });

    group('next', () {
      test('cycles all -> none', () {
        expect(AudioServiceShuffleMode.all.next, AudioServiceShuffleMode.none);
      });

      test('cycles none -> all', () {
        expect(AudioServiceShuffleMode.none.next, AudioServiceShuffleMode.all);
      });

      test('group falls through to none', () {
        expect(AudioServiceShuffleMode.group.next, AudioServiceShuffleMode.none);
      });

      test('double next returns to start', () {
        var mode = AudioServiceShuffleMode.all;
        mode = mode.next;
        mode = mode.next;
        expect(mode, AudioServiceShuffleMode.all);
      });
    });
  });
}
