import 'package:flutter/material.dart';
import 'package:music_player/common/common.dart' show HiddenThumbComponentShape;

class CustomAppTheme {
  final Color primaryTextColor;
  final Color accentColor;
  final Color mainBackgroundColor;
  final double fontSizeAdjustment;
  final double iconSizeAdjustment;
  final int baseFontSize = 20;
  final int baseLargeFontSize = 23;
  final int baseIconSize = 20;
  final int baseLargeIconSize = 27;
  CustomAppTheme({required this.mainBackgroundColor, required this.primaryTextColor, required this.accentColor, required this.fontSizeAdjustment, required this.iconSizeAdjustment});
  ThemeData get materialTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryTextColor, secondary: accentColor),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: accentColor),
      bodyMedium: TextStyle(color: primaryTextColor, fontSize: baseFontSize + fontSizeAdjustment),
      bodySmall: TextStyle(color: primaryTextColor.withAlpha(90), fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: primaryTextColor, fontSize: baseFontSize + fontSizeAdjustment),
      headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(color: Colors.lime),
      titleLarge: TextStyle(color: primaryTextColor, fontSize: baseLargeFontSize + fontSizeAdjustment),
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
    cardTheme: CardThemeData(color: mainBackgroundColor),
    dividerColor: Colors.transparent,
    dividerTheme: DividerThemeData(color: accentColor),
    listTileTheme: ListTileThemeData(
      iconColor: primaryTextColor,
      style: ListTileStyle.list,
      titleTextStyle: TextStyle(color: primaryTextColor, fontSize: baseFontSize + fontSizeAdjustment),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: primaryTextColor,
      iconTheme: WidgetStateProperty.all(IconThemeData(color: primaryTextColor, size: baseIconSize + iconSizeAdjustment, shadows: const [Shadow(blurRadius: 2)])),
    ),
    iconButtonTheme: IconButtonThemeData(style: ButtonStyle(iconSize: WidgetStateProperty.all(baseLargeIconSize + iconSizeAdjustment))),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: mainBackgroundColor,
        activeIndicatorBorder: const BorderSide(width: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        suffixStyle: TextStyle(color: primaryTextColor, fontSize: baseFontSize + fontSizeAdjustment),
        border: const UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
      ),
      menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{WidgetState.any: mainBackgroundColor})),
      textStyle: TextStyle(color: accentColor, fontSize: baseFontSize + fontSizeAdjustment),
    ),

    /// Seek bar
    sliderTheme: SliderThemeData(inactiveTrackColor: accentColor, thumbShape: HiddenThumbComponentShape(), activeTrackColor: primaryTextColor),
    iconTheme: IconThemeData(color: primaryTextColor, size: baseLargeIconSize + iconSizeAdjustment),
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
