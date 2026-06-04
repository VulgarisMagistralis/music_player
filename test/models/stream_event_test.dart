import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/src/rust/api/data/stream_event.dart';
import 'package:music_player/src/rust/api/data/song.dart';

void main() {
  group('StreamEvent', () {
    Song makeSong() => Song(id: BigInt.zero, path: '/storage/song.mp3', title: 'Test Song', artist: 'Test Artist', album: 'Test Album', lastModifiedAt: 0);

    test('creates song variant', () {
      final event = StreamEvent.song(makeSong());

      expect(event, isA<StreamEvent_Song>());
    });

    test('creates error variant', () {
      const event = StreamEvent.error('Something went wrong');

      expect(event, isA<StreamEvent_Error>());
    });

    test('creates done variant', () {
      const event = StreamEvent_Done();

      expect(event, isA<StreamEvent_Done>());
    });

    test('pattern matches song variant', () {
      final event = StreamEvent.song(makeSong());

      switch (event) {
        case StreamEvent_Song():
          expect(event.field0, isA<Song>());
        case StreamEvent_Error():
          fail('Should be song variant');
        case StreamEvent_Done():
          fail('Should be song variant');
      }
    });

    test('pattern matches error variant', () {
      final errorMessage = 'Database connection failed';
      final event = StreamEvent.error(errorMessage);

      switch (event) {
        case StreamEvent_Song():
          fail('Should be error variant');
        case StreamEvent_Error():
          expect(event.field0, errorMessage);
        case StreamEvent_Done():
          fail('Should be error variant');
      }
    });

    test('pattern matches done variant', () {
      const event = StreamEvent_Done();

      switch (event) {
        case StreamEvent_Song():
          fail('Should be done variant');
        case StreamEvent_Error():
          fail('Should be done variant');
        case StreamEvent_Done():
        // Correct variant matched
      }
    });

    test('song variant is not equal to error variant', () {
      final songEvent = StreamEvent.song(makeSong());
      const errorEvent = StreamEvent.error('error');

      expect(songEvent, isNot(errorEvent));
    });

    test('same song events are equal', () {
      final a = StreamEvent.song(makeSong());
      final b = StreamEvent.song(makeSong());

      expect(a, b);
    });

    test('same error messages are equal', () {
      const a = StreamEvent.error('same error');
      const b = StreamEvent.error('same error');

      expect(a, b);
    });

    test('done events are equal', () {
      const a = StreamEvent_Done();
      const b = StreamEvent_Done();

      expect(a, b);
    });
  });
}
