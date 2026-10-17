import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/generated/supported_locales.g.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/utilities/color_selector.dart';

void main() {
  testWidgets('tapping a setting color selector opens the picker dialog', (WidgetTester tester) async {
    bool updated = false;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          GeneratedLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
        home: Scaffold(
          body: SettingColorSelector(
            title: 'Background Color',
            provider: Provider<Color>((ref) => const Color(0x98000000)),
            onUpdate: (Color newColor) async {
              updated = true;
            },
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(SettingColorSelector));
    await tester.pumpAndSettle();

    expect(find.byType(ColorPicker), findsOneWidget, reason: 'Color picker dialog must open (MaterialLocalizations must resolve)');
    expect(tester.takeException(), isNull);
    expect(updated, isFalse);
  });
}
