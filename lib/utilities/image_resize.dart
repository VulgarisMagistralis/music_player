import 'dart:typed_data';
import 'package:image/image.dart';

Uint8List resizeAlbumArt(Uint8List bytes) {
  final image = decodeImage(bytes);
  if (image == null) return bytes;
  final resized = copyResize(image, width: 50, height: 50);
  return Uint8List.fromList(encodePng(resized));
}
