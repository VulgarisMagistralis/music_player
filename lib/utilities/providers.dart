import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

@riverpod
Stream readFiles(Ref ref, Directory musicDirectory) => musicDirectory.list(followLinks: false, recursive: false);

class SongTitle extends Notifier<String> {
  @override
  String build() => '';

  void updateTitle(String newTitle) => state = newTitle;
}

final getSongTitle = NotifierProvider<SongTitle, String>(SongTitle.new);

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
