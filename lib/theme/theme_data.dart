import 'package:flutter/material.dart';

/// font size -2, 0, +2?
/// icon size -3, 0, +3?

///Large icons, small icons
///Headers, default text, subtitles
///
class CustomAppTheme {
  final Color? primaryTextColor;
  final Color? accentColor;
  final Color? mainBackgroundColor;
  CustomAppTheme({this.mainBackgroundColor, this.primaryTextColor, this.accentColor});
  ThemeData get materialTheme => ThemeData(
        colorScheme: primaryTextColor == null ? null : ColorScheme.fromSeed(seedColor: primaryTextColor!, secondary: accentColor),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
          ),
          labelMedium: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
          ),
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
        listTileTheme: ListTileThemeData(
          iconColor: primaryTextColor,
          style: ListTileStyle.list,
          titleTextStyle: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primaryTextColor,
          iconTheme: WidgetStateProperty.all(IconThemeData(color: primaryTextColor, size: 20, shadows: const [
            Shadow(blurRadius: 2),
          ])),
        ),
        iconTheme: IconThemeData(color: primaryTextColor, size: 27),
        extensions: const [_CustomAppThemeExtension()],
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
