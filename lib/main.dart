import 'package:flutter/material.dart';
import 'package:music_player/pages/after_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPreferenceWithCacheHandler.instance.init();
  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: AfterSplash()));
}
