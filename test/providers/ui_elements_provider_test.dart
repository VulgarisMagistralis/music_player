import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:music_player/utilities/settings_data.dart';

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

  group('IconSizeAdjustmentProvider', () {
    const prefKey = 'behaviour.ui.icon_size_adjustment';

    test('returns default 0', () {
      expect(container.read(iconSizeAdjustmentProvider), 0);
    });

    test('update increments within bounds', () async {
      final notifier = container.read(iconSizeAdjustmentProvider.notifier);
      await notifier.update(2);
      expect(container.read(iconSizeAdjustmentProvider), 2);

      await _resetNotifier(iconSizeAdjustmentProvider, container, 0, prefKey);
    });

    test('update respects minimum bound of -5', () async {
      final notifier = container.read(iconSizeAdjustmentProvider.notifier);
      await _resetNotifier(iconSizeAdjustmentProvider, container, 0, prefKey);

      await notifier.update(-5);
      expect(container.read(iconSizeAdjustmentProvider), -5);

      await notifier.update(-1);
      expect(container.read(iconSizeAdjustmentProvider), -5);
    });

    test('update respects maximum bound of 5', () async {
      final notifier = container.read(iconSizeAdjustmentProvider.notifier);
      await _resetNotifier(iconSizeAdjustmentProvider, container, 0, prefKey);

      await notifier.update(5);
      expect(container.read(iconSizeAdjustmentProvider), 5);

      await notifier.update(1);
      expect(container.read(iconSizeAdjustmentProvider), 5);
    });
  });

  group('FontSizeAdjustmentProvider', () {
    const prefKey = 'behaviour.ui.font_size_adjustment';

    test('returns default 0', () {
      expect(container.read(fontSizeAdjustmentProvider), 0);
    });

    test('update increments within bounds', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await notifier.update(3);
      expect(container.read(fontSizeAdjustmentProvider), 3);

      await _resetNotifier(fontSizeAdjustmentProvider, container, 0, prefKey);
    });

    test('update respects minimum bound of -5', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await _resetNotifier(fontSizeAdjustmentProvider, container, 0, prefKey);

      await notifier.update(-5);
      expect(container.read(fontSizeAdjustmentProvider), -5);

      await notifier.update(-1);
      expect(container.read(fontSizeAdjustmentProvider), -5);
    });

    test('update respects maximum bound of 5', () async {
      final notifier = container.read(fontSizeAdjustmentProvider.notifier);
      await _resetNotifier(fontSizeAdjustmentProvider, container, 0, prefKey);

      await notifier.update(5);
      expect(container.read(fontSizeAdjustmentProvider), 5);

      await notifier.update(1);
      expect(container.read(fontSizeAdjustmentProvider), 5);
    });
  });

  group('ShowSongIconProvider', () {
    test('returns default false', () {
      expect(container.read(showSongIconProvider), isFalse);
    });

    test('setFlag updates state', () async {
      final notifier = container.read(showSongIconProvider.notifier);
      await notifier.setFlag(true);
      expect(container.read(showSongIconProvider), isTrue);
    });
  });

  group('ShuffleModeNotifier', () {
    test('returns default none', () {
      expect(container.read(shuffleModeProvider), AudioServiceShuffleMode.none);
    });

    test('setShuffleMode updates and persists', () async {
      final notifier = container.read(shuffleModeProvider.notifier);
      await notifier.setShuffleMode(AudioServiceShuffleMode.all);
      expect(container.read(shuffleModeProvider), AudioServiceShuffleMode.all);
    });
  });

  group('RepeatModeNotifier', () {
    test('returns default none', () {
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.none);
    });

    test('setRepeatMode updates and persists', () async {
      final notifier = container.read(repeatModeProvider.notifier);
      await notifier.setRepeatMode(AudioServiceRepeatMode.one);
      expect(container.read(repeatModeProvider), AudioServiceRepeatMode.one);
    });
  });
}

Future<void> _resetNotifier(provider, ProviderContainer container, int value, String key) async {
  await SharedPreferenceWithCacheHandler.instance.removeInteger(key);
  container.read(provider.notifier).state = value;
}
