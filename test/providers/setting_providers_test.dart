import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/providers/theme_colors.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/src/rust/api/utils/sort_modes.dart' show SortBy;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await SharedPreferenceWithCacheHandler.instance.init();
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('PlayOnLaunchProvider', () {
    test('returns default value when no value saved', () {
      expect(container.read(playOnLaunchProvider), isTrue);
    });

    test('setFlag updates state correctly', () async {
      final notifier = container.read(playOnLaunchProvider.notifier);
      await notifier.setFlag(false);
      expect(container.read(playOnLaunchProvider), isFalse);
    });
  });

  group('PlayOnConnectProvider', () {
    test('returns default value', () {
      expect(container.read(playOnConnectProvider), isTrue);
    });

    test('setFlag updates state', () async {
      final notifier = container.read(playOnConnectProvider.notifier);
      await notifier.setFlag(false);
      expect(container.read(playOnConnectProvider), isFalse);
    });
  });

  group('PauseOnHiddenProvider', () {
    test('returns default false', () {
      expect(container.read(pauseOnHiddenProvider), isFalse);
    });
  });

  group('PauseWhenMutedProvider', () {
    test('returns default false', () {
      expect(container.read(pauseWhenMutedProvider), isFalse);
    });
  });

  group('ResumeAfterDisconnectProvider', () {
    test('returns default false', () {
      expect(container.read(resumeAfterDisconnectProvider), isFalse);
    });
  });

  group('RewindIntervalInSecondsProvider', () {
    test('returns default value of 3', () {
      expect(container.read(rewindIntervalInSecondsProvider), 3);
    });

    test('update increments within bounds', () async {
      final notifier = container.read(rewindIntervalInSecondsProvider.notifier);
      await notifier.update(1);
      expect(container.read(rewindIntervalInSecondsProvider), 4);
    });

    test('update respects minimum bound', () async {
      final notifier = container.read(rewindIntervalInSecondsProvider.notifier);
      await SharedPreferenceWithCacheHandler.instance.saveInteger('behaviour.playback.rewind_interval_in_seconds', 3);
      notifier.state = 3;
      await notifier.update(-2); // 3 - 2 = 1 -> ok
      expect(container.read(rewindIntervalInSecondsProvider), 1);

      await notifier.update(-3); // 1 - 3 = -2 -> blocked (< 1)
      expect(container.read(rewindIntervalInSecondsProvider), 1);
    });

    test('update respects maximum bound', () async {
      final notifier = container.read(rewindIntervalInSecondsProvider.notifier);
      await SharedPreferenceWithCacheHandler.instance.saveInteger('behaviour.playback.rewind_interval_in_seconds', 3);
      notifier.state = 3;
      await notifier.update(8); // 3 + 8 = 11 -> blocked (> 10)
      expect(container.read(rewindIntervalInSecondsProvider), 3);
    });
  });

  group('FastForwardIntervalInSecondsProvider', () {
    test('returns default value of 3', () {
      expect(container.read(fastForwardIntervalInSecondsProvider), 3);
    });
  });

  group('CurrentLocaleProvider', () {
    test('returns default Locale(en)', () {
      expect(container.read(currentLocaleProvider), equals(Locale('en')));
    });
  });

  group('ShowSongIconProvider', () {
    test('returns default false', () {
      expect(container.read(showSongIconProvider), isFalse);
    });
  });

  group('ShowAndroidNavigationButtonsProvider', () {
    test('returns default false', () {
      expect(container.read(showAndroidNavigationButtonsProvider), isFalse);
    });
  });

  group('FontSizeAdjustmentProvider', () {
    test('returns default 0', () {
      expect(container.read(fontSizeAdjustmentProvider), 0);
    });

    test('update increments within bounds', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await notifier.update(1);
      expect(container.read(fontSizeAdjustmentProvider), 1);
    });

    test('update respects minimum bound of -5', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await SharedPreferenceWithCacheHandler.instance.saveInteger('behaviour.ui.font_size_adjustment', 0);
      notifier.state = 0;
      await notifier.update(-5); // 0 - 5 = -5
      expect(container.read(fontSizeAdjustmentProvider), -5);

      await notifier.update(-1); // -5 - 1 = -6 -> blocked
      expect(container.read(fontSizeAdjustmentProvider), -5);
    });

    test('update respects maximum bound of 5', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await SharedPreferenceWithCacheHandler.instance.saveInteger('behaviour.ui.font_size_adjustment', 0);
      notifier.state = 0;
      await notifier.update(6); // 0 + 6 = 6 -> blocked
      expect(container.read(fontSizeAdjustmentProvider), 0);
    });
  });

  group('IconSizeAdjustmentProvider', () {
    test('returns default 0', () {
      expect(container.read(iconSizeAdjustmentProvider), 0);
    });
  });

  group('ShuffleModeProvider', () {
    test('returns default shuffle mode none', () {
      expect(container.read(shuffleModeProvider), equals(AudioServiceShuffleMode.none));
    });
  });

  group('RepeatModeProvider', () {
    test('returns default repeat mode none', () {
      expect(container.read(repeatModeProvider), equals(AudioServiceRepeatMode.none));
    });
  });

  group('PrimaryTextColorProvider', () {
    test('returns default white', () {
      expect(container.read(primaryTextColorProvider), equals(Colors.white));
    });
  });

  group('PrimaryBackgroundColorProvider', () {
    test('returns default black', () {
      expect(container.read(primaryBackgroundColorProvider), equals(Colors.black));
    });
  });

  group('PrimaryAccentColorProvider', () {
    test('returns default amber', () {
      expect(container.read(primaryAccentColorProvider), equals(Colors.amber));
    });
  });

  group('PlayerThemeProvider', () {
    test('returns a ThemeData', () {
      expect(container.read(playerThemeProvider), isA<ThemeData>());
    });
  });

  group('Utility: AppReady', () {
    test('initial state is false', () {
      expect(container.read(appReadyProvider), isFalse);
    });

    test('setReady updates to true', () {
      container.read(appReadyProvider.notifier).setReady();
      expect(container.read(appReadyProvider), isTrue);
    });
  });

  group('Utility: SongsPageScrollOffset', () {
    test('initial state is 0.0', () {
      expect(container.read(songsPageScrollOffsetProvider), 0.0);
    });

    test('updateOffset updates value', () {
      container.read(songsPageScrollOffsetProvider.notifier).updateOffset(5.0);
      expect(container.read(songsPageScrollOffsetProvider), 5.0);
    });
  });

  group('Utility: PlaylistSortedBy', () {
    test('initial sort is dateModifiedDescending', () {
      final initial = container.read(playlistSortedByProvider);
      expect(initial, equals(SortBy.dateModifiedDescending));
    });

    test('update changes sort rule', () {
      container.read(playlistSortedByProvider.notifier).update(SortBy.nameAscending);
      expect(container.read(playlistSortedByProvider), equals(SortBy.nameAscending));
    });
  });
}
