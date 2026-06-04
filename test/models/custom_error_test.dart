import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/src/rust/api/error/custom_error.dart';

void main() {
  group('CustomError', () {
    test('creates dbError variant', () {
      const error = CustomError_DbError('connection failed');
      expect(error, isA<CustomError_DbError>());
    });

    test('creates utf8Error variant', () {
      const error = CustomError_Utf8Error();
      expect(error, isA<CustomError_Utf8Error>());
    });

    test('creates invalidPath variant', () {
      const error = CustomError_InvalidPath('/bad/path');
      expect(error, isA<CustomError_InvalidPath>());
    });

    test('creates treeError variant', () {
      const error = CustomError_TreeError('traversal failed');
      expect(error, isA<CustomError_TreeError>());
    });

    test('creates decodeError variant', () {
      const error = CustomError_DecodeError();
      expect(error, isA<CustomError_DecodeError>());
    });

    test('creates alreadyInitialized variant', () {
      const error = CustomError_AlreadyInitialized('init called twice');
      expect(error, isA<CustomError_AlreadyInitialized>());
    });

    test('creates encodeError variant', () {
      const error = CustomError_EncodeError();
      expect(error, isA<CustomError_EncodeError>());
    });

    test('creates playlistCollectionError variant', () {
      const error = CustomError_PlaylistCollectionError('collection not found');
      expect(error, isA<CustomError_PlaylistCollectionError>());
    });

    test('creates albumArtError variant', () {
      const error = CustomError_AlbumArtError();
      expect(error, isA<CustomError_AlbumArtError>());
    });

    test('creates playlistNotFound variant', () {
      const error = CustomError_PlaylistNotFound();
      expect(error, isA<CustomError_PlaylistNotFound>());
    });

    test('creates unknown variant', () {
      const error = CustomError_Unknown('unexpected failure');
      expect(error, isA<CustomError_Unknown>());
    });

    test('runtimeType contains CustomError', () {
      const error = CustomError_DbError('test');
      expect(error.runtimeType.toString(), contains('CustomError'));
    });

    test('pattern matches dbError variant', () {
      const error = CustomError_DbError('database down');
      switch (error) {
        case CustomError_DbError():
          expect(error.field0, 'database down');
      }
    });

    test('pattern matches unknown variant', () {
      const error = CustomError_Unknown('mystery error');
      switch (error) {
        case CustomError_Unknown():
          expect(error.field0, 'mystery error');
      }
    });

    test('same variants with same data are equal', () {
      const a = CustomError_InvalidPath('/same/path');
      const b = CustomError_InvalidPath('/same/path');
      expect(a, b);
    });

    test('different variants are not equal', () {
      const a = CustomError_DbError('error');
      const b = CustomError_Utf8Error();
      expect(a, isNot(b));
    });

    test('same variant different data are not equal', () {
      const a = CustomError_InvalidPath('/path1');
      const b = CustomError_InvalidPath('/path2');
      expect(a, isNot(b));
    });
  });
}
