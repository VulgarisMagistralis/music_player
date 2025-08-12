import 'dart:io' show FileSystemEntity;

class AudioSessionState {
  final String? title;
  final FileSystemEntity? file;
  final bool isReady;

  const AudioSessionState({this.title, this.file, this.isReady = false});

  factory AudioSessionState.initial() => const AudioSessionState();

  AudioSessionState copyWith({String? title, FileSystemEntity? file, bool? isReady}) {
    return AudioSessionState(title: title ?? this.title, file: file ?? this.file, isReady: isReady ?? this.isReady);
  }
}
