import 'dart:io' show FileSystemEntity;
import 'dart:typed_data' show Uint8List;

/// ISAR
class AudioSessionState {
  final String? title;
  final FileSystemEntity? file;
  final bool isReady;
  final Uint8List? albumArt;
  const AudioSessionState({this.albumArt, this.title, this.file, this.isReady = false});

  factory AudioSessionState.initial() => const AudioSessionState();

  AudioSessionState copyWith({String? title, FileSystemEntity? file, bool? isReady, Uint8List? albumArt}) =>
      AudioSessionState(title: title ?? this.title, file: file ?? this.file, isReady: isReady ?? this.isReady, albumArt: albumArt);
}
