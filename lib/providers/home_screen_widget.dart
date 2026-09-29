import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Name of the [AppWidgetProvider] on the Android side that renders the home screen widget.
const String androidWidgetProviderName = 'MusicWidgetProvider';
const String _widgetTextKey = 'widget_text';
const String _widgetAccentKey = 'widget_accent';
const String _widgetBackgroundKey = 'widget_background';

/// Links color updates to Home screen widget
///-----
String colorToAndroidHex(Color color) => '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// The widget background carries its own opacity, which the app background does not have.
Color applyWidgetBackgroundAlpha(Color color, int? alpha) => alpha == null ? color : Color((alpha & 0xFF) << 24 | (color.toARGB32() & 0xFFFFFF));

/// Persist [color] under [key] in the `HomeWidgetPreferences` store that
/// `MusicWidgetProvider.applyTheme` reads on every render.
///
/// Returns false when the host cannot service the `home_widget` channel (unit tests,
/// desktop) or the write failed, so callers skip the re-render instead of throwing.
/// Throwing here would be costly: the startup sync runs before `runApp`.
Future<bool> _saveWidgetColor(String key, Color color) async {
  if (!Platform.isAndroid) return false;
  try {
    await HomeWidget.saveWidgetData<String>(key, colorToAndroidHex(color));
    return true;
  } catch (e) {
    debugPrint('HomeWidget: could not save $key — $e');
    return false;
  }
}

/// Ask the launcher to re-render the widget. No-ops when the plugin is unavailable.
Future<void> _refreshWidget() async {
  try {
    await HomeWidget.updateWidget(androidName: androidWidgetProviderName);
  } catch (e) {
    debugPrint('HomeWidget: could not request widget update — $e');
  }
}

Future<void> updateHomeScreenWidgetTextTheme(Color newColor) async {
  if (!await _saveWidgetColor(_widgetTextKey, newColor)) return;
  await _refreshWidget();
}

Future<void> updateHomeScreenWidgetAccentTheme(Color newColor) async {
  if (!await _saveWidgetColor(_widgetAccentKey, newColor)) return;
  await _refreshWidget();
}

Future<void> updateHomeScreenWidgetBackgroundTheme(Color newColor, {int? alpha}) async {
  if (!await _saveWidgetColor(_widgetBackgroundKey, applyWidgetBackgroundAlpha(newColor, alpha))) return;
  await _refreshWidget();
}

/// Push the app's *whole* theme to the widget in a single re-render.
///
/// Used at startup so the home screen tile matches the theme the app actually resolved
/// from storage, instead of only catching up whenever the user happens to change a color.
/// Writing all three keys before re-rendering once (rather than once per key) means the
/// widget can never be observed wearing a half-applied theme.
Future<void> updateHomeScreenWidgetTheme({required Color textColor, required Color backgroundColor, required Color accentColor, int? backgroundAlpha}) async {
  if (!Platform.isAndroid) return;
  final Map<String, Color> colors = <String, Color>{_widgetTextKey: textColor, _widgetAccentKey: accentColor, _widgetBackgroundKey: applyWidgetBackgroundAlpha(backgroundColor, backgroundAlpha)};
  for (final MapEntry<String, Color> entry in colors.entries) {
    if (!await _saveWidgetColor(entry.key, entry.value)) return;
  }
  await _refreshWidget();
}
