import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/custom_action_mode.dart';

void main() {
  group('CustomActionMode.getCustomActionOrNull', () {
    test('returns repeatMode for known repeatMode string', () {
      expect(CustomActionMode.getCustomActionOrNull('repeatMode'), CustomActionMode.repeatMode);
    });

    test('returns shuffleMode for known shuffleMode string', () {
      expect(CustomActionMode.getCustomActionOrNull('shuffleMode'), CustomActionMode.shuffleMode);
    });

    test('returns null for unknown string', () {
      expect(CustomActionMode.getCustomActionOrNull('unknownMode'), isNull);
    });

    test('returns null for empty string', () {
      expect(CustomActionMode.getCustomActionOrNull(''), isNull);
    });

    test('returns null for case mismatch', () {
      expect(CustomActionMode.getCustomActionOrNull('RepeatMode'), isNull);
    });

    test('covers all enum values', () {
      for (final mode in CustomActionMode.values) {
        expect(CustomActionMode.getCustomActionOrNull(mode.name), mode);
      }
    });
  });
}
