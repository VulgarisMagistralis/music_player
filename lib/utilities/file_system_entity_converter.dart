import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

class FileSystemEntityConverter
    implements JsonConverter<FileSystemEntity?, String?> {
  const FileSystemEntityConverter();

  @override
  FileSystemEntity? fromJson(String? path) => path != null ? File(path) : null;

  @override
  String? toJson(FileSystemEntity? file) => file?.path;
}
