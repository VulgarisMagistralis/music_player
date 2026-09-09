import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Links color updates to Home screen widget
///-----
String colorToAndroidHex(Color color) => '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

Future<void> updateHomeScreenWidgetTextTheme(Color newColor) async {
  await HomeWidget.saveWidgetData<String>('widget_text', colorToAndroidHex(newColor));
  await HomeWidget.updateWidget(androidName: 'MusicWidgetProvider');
}

Future<void> updateHomeScreenWidgetAccentTheme(Color newColor) async {
  await HomeWidget.saveWidgetData<String>('widget_accent', colorToAndroidHex(newColor));
  await HomeWidget.updateWidget(androidName: 'MusicWidgetProvider');
}

Future<void> updateHomeScreenWidgetBackgroundTheme(Color newColor, {int? alpha}) async {
  final Color colorWithAlpha = alpha == null ? newColor : Color((alpha & 0xFF) << 24 | (newColor.toARGB32() & 0xFFFFFF));
  await HomeWidget.saveWidgetData<String>('widget_background', colorToAndroidHex(colorWithAlpha));
  await HomeWidget.updateWidget(androidName: 'MusicWidgetProvider');
}
