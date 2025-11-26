import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/theme/theme_providers.dart';
import 'package:music_player/low_level_wrapper/init.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_player/utilities/providers.dart' show audioHandlerProvider;

void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPreferenceWithCacheHandler.instance.init();
  await LowLevelInitializer.init();
  final ProviderContainer providerContainer = ProviderContainer();
  await _initializeAudioServices(providerContainer);
  FlutterNativeSplash.remove();
  runApp(UncontrolledProviderScope(container: providerContainer, child: const AfterSplash()));
}

Future<void> _initializeAudioServices(ProviderContainer providerContainer) async {
  final PlayerAudioHandler handler = providerContainer.read(audioHandlerProvider);
  providerContainer.read(playerThemeProvider.notifier).loadStoredThemeData();
  try {
    await _initializeBackgroundAudio();
    handler.init();
  } catch (e) {
    ToastManager().showErrorToast('Failed to start audio services');
    debugPrint('Background init error: $e');
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

Future<void> _initializeBackgroundAudio() async => await JustAudioBackground.init(
  notificationColor: Colors.amber,
  androidNotificationOngoing: true,
  androidNotificationChannelName: 'Audio playback',
  androidNotificationChannelId: 'com.cenkt.music_player',
  androidNotificationIcon: 'mipmap/ic_launcher_foreground',
  rewindInterval: const Duration(seconds: 3),
  fastForwardInterval: const Duration(seconds: 3),
  androidBrowsableRootExtras: {},
  preloadArtwork: true,
);
