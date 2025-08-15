import 'package:flutter/material.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:just_audio_background/just_audio_background.dart' show JustAudioBackground;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPreferenceWithCacheHandler.instance.init();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.cenkt.music_player',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher_foreground',
    );
  } catch (e) {
    debugPrint("Background init error: $e");
    //exit
  }
  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: AfterSplash()));
}
