import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:music_player/providers/home_screen_widget.dart';
import 'package:music_player/providers/ui_elements.dart';
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
  ThemeData build() => CustomAppTheme(
    primaryTextColor: ref.watch(primaryTextColorProvider),
    mainBackgroundColor: ref.watch(primaryBackgroundColorProvider),
    accentColor: ref.watch(primaryAccentColorProvider),
    fontSizeAdjustment: ref.watch(fontSizeAdjustmentProvider).toDouble(),
    iconSizeAdjustment: ref.watch(iconSizeAdjustmentProvider).toDouble(),
  ).materialTheme;
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
    await updateHomeScreenWidgetTextTheme(newColor);
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
    await updateHomeScreenWidgetBackgroundTheme(newColor, alpha: ref.read(widgetBackgroundAlphaProvider));
    state = newColor;
  }
}

/// Opacity of the home screen widget background only — does not affect the app background color
@Riverpod(keepAlive: true)
class WidgetBackgroundAlpha extends _$WidgetBackgroundAlpha {
  static const int _minimum = 40;
  static const int _maximum = 255;
  static const int _defaultState = 255;
  static const String _sharedPrefKey = 'widget.background.alpha';
  @override
  int build() => SharedPreferenceWithCacheHandler.instance.loadInteger(_sharedPrefKey) ?? _defaultState;
  Future<void> update(int newValue) async {
    if (newValue < _minimum || newValue > _maximum) return;
    await SharedPreferenceWithCacheHandler.instance.saveInteger(_sharedPrefKey, newValue);
    final Color baseColor = SharedPreferenceWithCacheHandler.instance.loadColor(PrimaryBackgroundColor._sharedPrefKey) ?? PrimaryBackgroundColor._defaultState;
    await updateHomeScreenWidgetBackgroundTheme(baseColor, alpha: newValue);
    state = newValue;
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
    await updateHomeScreenWidgetAccentTheme(newColor);
    state = newColor;
  }
}

@Riverpod(keepAlive: true)
class HomeScreenWidgetTheme extends _$HomeScreenWidgetTheme {
  @override
  void build() {}

  Future<void> sync() => updateHomeScreenWidgetTheme(
    textColor: ref.read(primaryTextColorProvider),
    backgroundColor: ref.read(primaryBackgroundColorProvider),
    accentColor: ref.read(primaryAccentColorProvider),
    backgroundAlpha: ref.read(widgetBackgroundAlphaProvider),
  );
}
