import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/position.dart';

void main() {
  group('PositionData', () {
    final position = const Duration(seconds: 30);
    final bufferedPosition = const Duration(seconds: 60);
    final duration = const Duration(seconds: 180);

    test('creates with correct values', () {
      final pData = PositionData(position, bufferedPosition, duration);

      expect(pData.position, position);
      expect(pData.bufferedPosition, bufferedPosition);
      expect(pData.duration, duration);
    });

    test('handles zero values', () {
      final zero = Duration.zero;
      final pData = PositionData(zero, zero, duration);

      expect(pData.position, zero);
      expect(pData.bufferedPosition, zero);
      expect(pData.duration, duration);
    });

    test('progress calculation is correct', () {
      final pData = PositionData(position, bufferedPosition, duration);
      final progress = pData.position.inMilliseconds / pData.duration.inMilliseconds;

      expect(progress, 30 / 180);
    });

    test('buffered progress calculation is correct', () {
      final pData = PositionData(position, bufferedPosition, duration);
      final bufferedProgress = pData.bufferedPosition.inMilliseconds / pData.duration.inMilliseconds;

      expect(bufferedProgress, 60 / 180);
    });
  });
}
