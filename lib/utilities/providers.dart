import 'dart:io';
import 'package:music_player/data/song.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

@riverpod
Stream readFiles(Ref ref, Directory musicDirectory) => musicDirectory.list(followLinks: false, recursive: false);

@Riverpod(keepAlive: true)
class SongsPageScrollOffset extends _$SongsPageScrollOffset {
  @override
  double build() => state = 0.0;
  double get value => state;
  void updateOffset(double newOffset) => state = newOffset;
}

final audioSessionManagerProvider = AsyncNotifierProvider<AudioSessionManager, AudioSessionState>(() => AudioSessionManager());

@riverpod
Future<List<FileSystemEntity>> readSongFileList(Ref ref, List<String> musicDirectoryList) async {
  List<FileSystemEntity> songs = [];
  try {
    int i = 0;
    while (i < musicDirectoryList.length) {
      Directory dir = Directory(musicDirectoryList[i++]);
      List<FileSystemEntity> files = dir.listSync(recursive: false, followLinks: false);
      for (FileSystemEntity entity in files) {
        String path = entity.path;

        ///more extensions?
        if (path.endsWith('.mp3')) songs.add(entity);
      }
      print(songs.length);
    }
  } catch (e) {
    print(e.toString());
  }
  return songs;
}
