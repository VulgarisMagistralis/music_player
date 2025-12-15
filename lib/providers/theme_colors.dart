import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/theme/theme_data.dart' show CustomAppTheme;
part 'theme_colors.g.dart';
//TODO
// SystemChrome.setSystemUIOverlayStyle(
// SystemUiOverlayStyle(
// systemNavigationBarColor: Colors.amberAccent,
// systemStatusBarContrastEnforced: true,
// statusBarBrightness: Brightness.light,
// statusBarIconBrightness: Brightness.light,
// statusBarColor: Colors.red,
// systemNavigationBarIconBrightness: Brightness.light,
// systemStatusBarContrastEnforced: false,
// systemNavigationBarDividerColor: Colors.blue,

@Riverpod(keepAlive: true)
class PlayerTheme extends _$PlayerTheme {
  @override
  ThemeData build() =>
      CustomAppTheme(primaryTextColor: ref.watch(primaryTextColorProvider), mainBackgroundColor: ref.watch(primaryBackgroundColorProvider), accentColor: ref.watch(primaryAccentColorProvider)).materialTheme;
}

@Riverpod(keepAlive: true)
class PrimaryTextColor extends _$PrimaryTextColor {
  static const Color _defaultState = Colors.white;
  static const String _sharedPrefKey = 'theme.text.primary_color';
  @override
  Color build() => SharedPreferenceWithCacheHandler.instance.loadColor(_sharedPrefKey) ?? _defaultState;
  Future<void> update(Color? newColor) async {
    if (newColor == null) return;
    await SharedPreferenceWithCacheHandler.instance.saveColor(_sharedPrefKey, newColor.value32bit);
    state = newColor;
  }
}

/// todo add bool for OS button background match
@Riverpod(keepAlive: true)
class PrimaryBackgroundColor extends _$PrimaryBackgroundColor {
  static const Color _defaultState = Colors.black;
  static const String _sharedPrefKey = 'theme.background.primary_color';
  @override
  Color build() => SharedPreferenceWithCacheHandler.instance.loadColor(_sharedPrefKey) ?? _defaultState;
  Future<void> update(Color? newColor) async {
    if (newColor == null) return;
    await SharedPreferenceWithCacheHandler.instance.saveColor(_sharedPrefKey, newColor.value32bit);
    state = newColor;
  }
}

@Riverpod(keepAlive: true)
class PrimaryAccentColor extends _$PrimaryAccentColor {
  static const Color _defaultState = Colors.amber;
  static const String _sharedPrefKey = 'theme.accent.primary_color';
  @override
  Color build() => SharedPreferenceWithCacheHandler.instance.loadColor(_sharedPrefKey) ?? _defaultState;
  Future<void> update(Color? newColor) async {
    if (newColor == null) return;
    await SharedPreferenceWithCacheHandler.instance.saveColor(_sharedPrefKey, newColor.value32bit);
    state = newColor;
  }
}
