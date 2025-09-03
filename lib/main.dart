import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_player/utilities/providers.dart' show audioHandlerProvider;

void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPreferenceWithCacheHandler.instance.init();
  final ProviderContainer providerContainer = ProviderContainer();
  final PlayerAudioHandler handler = providerContainer.read(audioHandlerProvider);
  try {
    await AudioService.init(
      config: const AudioServiceConfig(
        preloadArtwork: true,
        androidNotificationChannelName: 'Audio playback',
        androidNotificationChannelId: 'com.cenkt.music_player',
        androidNotificationIcon: 'mipmap/ic_launcher_foreground',
        // to settings
        rewindInterval: Duration(seconds: 3),
        fastForwardInterval: Duration(seconds: 3),
        notificationColor: Colors.amber,
        androidBrowsableRootExtras: {},
        androidStopForegroundOnPause: false,
      ),
      builder: () => handler,
    );
    await handler.init();
  } catch (e) {
    ToastManager().showErrorToast('Failed to start audio services');
    debugPrint('Background init error: $e');
    await Future.delayed(const Duration(seconds: 3));
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
  FlutterNativeSplash.remove();
  runApp(UncontrolledProviderScope(container: providerContainer, child: const AfterSplash()));
}
