import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utilities/thumbnail_uri.dart';

void main() {
  group('getThumbnailUri', () {
    test('returns content URI with correct scheme and authority', () {
      final uri = getThumbnailUri('/storage/emulated/0/Music/song.mp3');
      final parsed = Uri.parse(uri);
      expect(parsed.scheme, 'content');
      expect(parsed.host, 'com.cenkt.music_player.artwork');
      expect(parsed.path, '/storage/emulated/0/Music/song.mp3');
    });

    test('handles paths with spaces', () {
      final uri = getThumbnailUri('/storage/Music/My Song.mp3');
      final parsed = Uri.parse(uri);
      expect(parsed.path, '/storage/Music/My%20Song.mp3');
    });

    test('handles SD card paths', () {
      final uri = getThumbnailUri('/storage/1234-5678/Music/track.mp3');
      final parsed = Uri.parse(uri);
      expect(parsed.path, '/storage/1234-5678/Music/track.mp3');
    });

    test('handles empty path', () {
      final uri = getThumbnailUri('');
      final parsed = Uri.parse(uri);
      expect(parsed.path, isEmpty);
    });

    test('URL-encodes special characters in path', () {
      final uri = getThumbnailUri('/storage/Music/song (1).mp3');
      final parsed = Uri.parse(uri);
      expect(parsed.path, '/storage/Music/song%20(1).mp3');
    });
  });
}
