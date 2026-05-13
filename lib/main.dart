import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/low_level_wrapper/init.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/utilities/audio_handler.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_player/utilities/providers.dart' show audioHandlerProvider, appReadyProvider;
import 'package:flutter/services.dart' show SystemChannels, SystemChrome, SystemUiMode, SystemUiOverlay;

void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final ProviderContainer providerContainer = ProviderContainer();
  await _initializeAudioServices(providerContainer);
  providerContainer.read(appReadyProvider.notifier).setReady();
  runApp(UncontrolledProviderScope(container: providerContainer, child: const AfterSplash()));
  await Future.delayed(Duration.zero);
  FlutterNativeSplash.remove();
}

Future<void> _initializeAudioServices(ProviderContainer providerContainer) async {
  await SharedPreferenceWithCacheHandler.instance.init();
  await LowLevelInitializer.init();
  SystemChrome.setEnabledSystemUIMode(providerContainer.read(showAndroidNavigationButtonsProvider) ? SystemUiMode.edgeToEdge : SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  final PlayerAudioHandler handler = await providerContainer.read(audioHandlerProvider.future);
  try {
    await handler.init(providerContainer);
    handler.restoreSession();
  } catch (e) {
    final GeneratedLocalization locale = await GeneratedLocalization.delegate.load(providerContainer.read(currentLocaleProvider));
    ToastManager().showErrorToast(locale.toast_audio_start_failed);
    debugPrint('Background init error: $e');
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
