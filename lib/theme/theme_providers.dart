import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_player/data/theme_keys.dart' show ThemeKeys;
import 'package:music_player/theme/theme_data.dart' show CustomAppTheme;
part 'theme_providers.g.dart';

@Riverpod(keepAlive: true)
class PlayerTheme extends _$PlayerTheme {
  @override
  ThemeData build() => CustomAppTheme(
        primaryTextColor: ref.watch(basicColorProvider(ThemeKeys.primaryTextColor)),
        mainBackgroundColor: ref.watch(basicColorProvider(ThemeKeys.mainBackgroundColor)),
      ).materialTheme;

  Future<void> loadStoredThemeData() async {
    await ref.read(basicColorProvider(ThemeKeys.mainBackgroundColor).notifier).loadFromStorage();
    final Color backgroundColor = ref.watch(basicColorProvider(ThemeKeys.mainBackgroundColor));

    await ref.read(basicColorProvider(ThemeKeys.primaryTextColor).notifier).loadFromStorage();
    final Color primaryTextColor = ref.watch(basicColorProvider(ThemeKeys.primaryTextColor));
    state = CustomAppTheme(
      primaryTextColor: primaryTextColor,
      mainBackgroundColor: backgroundColor,
    ).materialTheme;
  }
}

@Riverpod(keepAlive: true)
class BasicColor extends _$BasicColor {
  late String storageKey;
  @override
  Color build(String storageKey) {
    this.storageKey = storageKey;
    loadFromStorage();
    return Colors.black;
  }

  Future<void> update(Color? color) async {
    if (color == null) return;
    await SharedPreferenceWithCacheHandler.instance.saveColor(storageKey, color.value32bit);
    state = color;
  }

  Future<void> loadFromStorage() async => state = await SharedPreferenceWithCacheHandler.instance.loadColor(storageKey) ?? Colors.black;
}
