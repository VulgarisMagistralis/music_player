import 'dart:convert';
import 'dart:typed_data' show Uint8List;
import 'package:freezed_annotation/freezed_annotation.dart';

class Uint8ListBase64Converter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListBase64Converter();

  @override
  Uint8List? fromJson(String? base64String) => base64String == null ? null : base64Decode(base64String);

  @override
  String? toJson(Uint8List? bytes) => bytes == null ? null : base64Encode(bytes);
}
