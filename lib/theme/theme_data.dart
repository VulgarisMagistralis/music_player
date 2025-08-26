import 'package:flutter/material.dart';

/// font size -2, 0, +2?
/// icon size -3, 0, +3?

///Large icons, small icons
///Headers, default text, subtitles
///
class CustomAppTheme {
  final Color? primaryTextColor;
  final Color? mainBackgroundColor;
  CustomAppTheme({this.mainBackgroundColor, this.primaryTextColor});
  ThemeData get materialTheme => ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
          ),
          labelMedium: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
          ),
          displayMedium: TextStyle(color: primaryTextColor),
          titleMedium: TextStyle(color: Colors.lime),
          titleLarge: TextStyle(color: Colors.lime),
          titleSmall: TextStyle(color: Colors.lime),
        ),
        scaffoldBackgroundColor: mainBackgroundColor,
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
          iconTheme: WidgetStateProperty.all(IconThemeData(color: primaryTextColor, size: 20, shadows: [
            Shadow(blurRadius: 2, color: Colors.black),
          ])),
        ),
        iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
          iconColor: WidgetStateProperty.all(primaryTextColor),
        )),
        extensions: [_CustomAppThemeExtension()],
      );
}

@immutable
class _CustomAppThemeExtension extends ThemeExtension<_CustomAppThemeExtension> {
  const _CustomAppThemeExtension();

  @override
  _CustomAppThemeExtension copyWith() {
    return _CustomAppThemeExtension();
  }

  @override
  _CustomAppThemeExtension lerp(ThemeExtension<_CustomAppThemeExtension>? other, double t) {
    if (other is! _CustomAppThemeExtension) return this;
    return _CustomAppThemeExtension();
  }
}
