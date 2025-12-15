import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/low_level_wrapper/init.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_player/utilities/providers.dart' show audioHandlerProvider;
import 'package:flutter/services.dart' show SystemChannels, SystemChrome, SystemUiMode, SystemUiOverlay;

void main() {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final ProviderContainer providerContainer = ProviderContainer();
  runApp(UncontrolledProviderScope(container: providerContainer, child: const AfterSplash()));
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await SharedPreferenceWithCacheHandler.instance.init();
    await LowLevelInitializer.init();
    SystemChrome.setEnabledSystemUIMode(providerContainer.read(showAndroidNavigationButtonsProvider) ? SystemUiMode.edgeToEdge : SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    await _initializeAudioServices(providerContainer);
    FlutterNativeSplash.remove();
  });
}

Future<void> _initializeAudioServices(ProviderContainer providerContainer) async {
  final PlayerAudioHandler handler = providerContainer.read(audioHandlerProvider);
  try {
    await _initializeBackgroundAudio();
    handler.init(providerContainer);
    handler.restoreSession(providerContainer);
  } catch (e) {
    ToastManager().showErrorToast('Failed to start audio services');
    debugPrint('Background init error: $e');
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

Future<void> _initializeBackgroundAudio() async => await JustAudioBackground.init(
  androidNotificationOngoing: true,
  androidNotificationChannelName: 'Audio playback',
  androidNotificationChannelId: 'com.cenkt.music_player',
  androidNotificationIcon: 'mipmap/ic_launcher_foreground',
  rewindInterval: const Duration(seconds: 3),
  fastForwardInterval: const Duration(seconds: 3),
  androidBrowsableRootExtras: {},
  preloadArtwork: true,
);
