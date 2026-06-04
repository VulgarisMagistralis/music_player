import 'package:audio_service/audio_service.dart' show AudioServiceShuffleMode, AudioServiceRepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:music_player/tools/conversion/shuffle_mode.dart';
import 'package:music_player/tools/conversion/loop_mode_conversion.dart';

void main() {
  group('AudioServiceShuffleModeExt', () {
    group('androidIcon', () {
      test('returns correct drawable for each shuffle mode', () {
        expect(AudioServiceShuffleMode.none.androidIcon, 'drawable/ic_shuffle');
        expect(AudioServiceShuffleMode.all.androidIcon, 'drawable/ic_shuffle_active');
        expect(AudioServiceShuffleMode.group.androidIcon, 'drawable/ic_shuffle');
      });
    });

    group('label', () {
      test('returns correct label for each shuffle mode', () {
        expect(AudioServiceShuffleMode.none.label, 'Shuffle off');
        expect(AudioServiceShuffleMode.all.label, 'Shuffle all');
        expect(AudioServiceShuffleMode.group.label, 'Shuffle off');
      });
    });

    group('next', () {
      test('cycles through shuffle modes correctly', () {
        expect(AudioServiceShuffleMode.none.next, AudioServiceShuffleMode.all);
        expect(AudioServiceShuffleMode.all.next, AudioServiceShuffleMode.none);
        expect(AudioServiceShuffleMode.group.next, AudioServiceShuffleMode.none);
      });
    });
  });

  group('AudioServiceRepeatModeExt', () {
    group('next', () {
      test('cycles through repeat modes correctly', () {
        expect(AudioServiceRepeatMode.none.next, AudioServiceRepeatMode.all);
        expect(AudioServiceRepeatMode.all.next, AudioServiceRepeatMode.one);
        expect(AudioServiceRepeatMode.one.next, AudioServiceRepeatMode.none);
      });
    });

    group('toLoopMode', () {
      test('converts to corresponding LoopMode', () {
        expect(AudioServiceRepeatMode.none.toLoopMode(), LoopMode.off);
        expect(AudioServiceRepeatMode.all.toLoopMode(), LoopMode.all);
        expect(AudioServiceRepeatMode.one.toLoopMode(), LoopMode.one);
      });
    });

    group('androidIcon', () {
      test('returns correct drawable for each repeat mode', () {
        expect(AudioServiceRepeatMode.none.androidIcon, 'drawable/ic_repeat');
        expect(AudioServiceRepeatMode.all.androidIcon, 'drawable/ic_repeat_active');
        expect(AudioServiceRepeatMode.one.androidIcon, 'drawable/ic_repeat_one_active');
        expect(AudioServiceRepeatMode.group.androidIcon, 'drawable/ic_repeat');
      });
    });

    group('label', () {
      test('returns correct label for each repeat mode', () {
        expect(AudioServiceRepeatMode.none.label, 'Repeat off');
        expect(AudioServiceRepeatMode.all.label, 'Repeat all');
        expect(AudioServiceRepeatMode.one.label, 'Repeat one');
        expect(AudioServiceRepeatMode.group.label, 'Repeat all');
      });
    });
  });

  group('LoopModeExt', () {
    group('toAudioServiceRepeatMode', () {
      test('converts to corresponding AudioServiceRepeatMode', () {
        expect(LoopMode.off.toAudioServiceRepeatMode(), AudioServiceRepeatMode.none);
        expect(LoopMode.all.toAudioServiceRepeatMode(), AudioServiceRepeatMode.all);
        expect(LoopMode.one.toAudioServiceRepeatMode(), AudioServiceRepeatMode.one);
      });
    });

    group('shuffleIcon', () {
      test('returns correct icon per loop mode', () {
        expect(LoopMode.off.shuffleIcon, 'drawable/ic_shuffle');
        expect(LoopMode.one.shuffleIcon, 'drawable/ic_shuffle');
        expect(LoopMode.all.shuffleIcon, 'drawable/ic_shuffle_active');
      });
    });

    group('shuffleLabel', () {
      test('returns correct label per loop mode', () {
        expect(LoopMode.off.shuffleLabel, 'Shuffle off');
        expect(LoopMode.one.shuffleLabel, 'Shuffle off');
        expect(LoopMode.all.shuffleLabel, 'Shuffle on');
      });
    });
  });
}
