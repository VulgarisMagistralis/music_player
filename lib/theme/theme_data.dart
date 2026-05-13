import 'package:flutter/material.dart';
import 'package:music_player/common/common.dart' show HiddenThumbComponentShape;

///Large icons, small icons
///Headers, default text, subtitles
///
class CustomAppTheme {
  final Color primaryTextColor;
  final Color accentColor;
  final Color mainBackgroundColor;
  final double fontSizeAdjustment;
  final double iconSizeAdjustment;
  CustomAppTheme({required this.mainBackgroundColor, required this.primaryTextColor, required this.accentColor, required this.fontSizeAdjustment, required this.iconSizeAdjustment});
  ThemeData get materialTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryTextColor, secondary: accentColor),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: accentColor),
      bodyMedium: TextStyle(color: primaryTextColor, fontSize: 20),
      bodySmall: TextStyle(color: primaryTextColor),
      labelMedium: TextStyle(color: primaryTextColor, fontSize: 20),
      headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(color: Colors.lime),
      titleLarge: const TextStyle(color: Colors.lime),
      titleSmall: const TextStyle(color: Colors.lime),
    ),
    scaffoldBackgroundColor: mainBackgroundColor,
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: primaryTextColor,
      textColor: primaryTextColor,
      collapsedTextColor: primaryTextColor,
      collapsedIconColor: primaryTextColor,
      childrenPadding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
    ),
    dividerColor: Colors.transparent,
    dividerTheme: DividerThemeData(color: accentColor),
    listTileTheme: ListTileThemeData(
      iconColor: primaryTextColor,
      style: ListTileStyle.list,
      titleTextStyle: TextStyle(color: primaryTextColor, fontSize: 20 + fontSizeAdjustment),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: primaryTextColor,
      iconTheme: WidgetStateProperty.all(IconThemeData(color: primaryTextColor, size: 20 + iconSizeAdjustment, shadows: const [Shadow(blurRadius: 2)])),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: mainBackgroundColor,
        activeIndicatorBorder: const BorderSide(width: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        suffixStyle: TextStyle(color: primaryTextColor, fontSize: 20 + fontSizeAdjustment),
        border: const UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
      ),
      menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{WidgetState.any: mainBackgroundColor})),
      textStyle: TextStyle(color: accentColor, fontSize: 20 + fontSizeAdjustment),
    ),

    /// Seek bar
    sliderTheme: SliderThemeData(inactiveTrackColor: accentColor, thumbShape: HiddenThumbComponentShape(), activeTrackColor: primaryTextColor),
    iconTheme: IconThemeData(color: primaryTextColor, size: 27 + iconSizeAdjustment),
    extensions: const [_CustomAppThemeExtension()],
    switchTheme: SwitchThemeData(
      splashRadius: 0.0,
      trackOutlineColor: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{WidgetState.any: accentColor}),
      trackColor: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{WidgetState.any: mainBackgroundColor}),
      thumbColor: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{WidgetState.any: primaryTextColor}),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: const UnderlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryTextColor)),
    ),
  );
}

@immutable
class _CustomAppThemeExtension extends ThemeExtension<_CustomAppThemeExtension> {
  const _CustomAppThemeExtension();

  @override
  _CustomAppThemeExtension copyWith() {
    return const _CustomAppThemeExtension();
  }

  @override
  _CustomAppThemeExtension lerp(ThemeExtension<_CustomAppThemeExtension>? other, double t) {
    if (other is! _CustomAppThemeExtension) return this;
    return const _CustomAppThemeExtension();
  }
}
