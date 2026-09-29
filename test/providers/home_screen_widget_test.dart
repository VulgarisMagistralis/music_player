import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/providers/home_screen_widget.dart';

void main() {
  group('colorToAndroidHex', () {
    test('emits #AARRGGBB, the format Color.parseColor expects', () {
      expect(colorToAndroidHex(Colors.white), '#FFFFFFFF');
      expect(colorToAndroidHex(Colors.black), '#FF000000');
      expect(colorToAndroidHex(Colors.amber), '#FFFFC107');
    });

    test('keeps the alpha channel and pads short values', () {
      expect(colorToAndroidHex(const Color(0x0000FF00)), '#0000FF00');
      expect(colorToAndroidHex(const Color(0xFF102030)), '#FF102030');
    });
  });

  group('applyWidgetBackgroundAlpha', () {
    test('replaces only the alpha channel, keeping the rgb triplet', () {
      expect(applyWidgetBackgroundAlpha(Colors.white, 40), const Color(0x28FFFFFF));
      expect(applyWidgetBackgroundAlpha(const Color(0xFF102030), 255), const Color(0xFF102030));
    });

    test('leaves the color untouched when no alpha is given', () {
      expect(applyWidgetBackgroundAlpha(Colors.amber, null), Colors.amber);
    });

    test('the rendered hex stays parseable by the Android side', () {
      // MusicWidgetProvider.applyTheme reads this straight into Color.parseColor, so a
      // widget background must never serialize to something the platform rejects.
      const List<int> alphas = <int>[0, 40, 128, 254, 255];
      for (final int alpha in alphas) {
        final String hex = colorToAndroidHex(applyWidgetBackgroundAlpha(Colors.amber, alpha));
        expect(hex, matches(RegExp(r'^#[0-9A-F]{8}$')));
      }
    });
  });
}
