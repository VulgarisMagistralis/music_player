import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;

class MediaItemConverter
    implements JsonConverter<MediaItem?, Map<String, dynamic>?> {
  const MediaItemConverter();

  @override
  MediaItem? fromJson(Map<String, dynamic>? json) => json == null
      ? null
      : MediaItem(
          id: json['id'] as String,
          title: json['title'] as String,
          duration: json['duration'] != null
              ? Duration(milliseconds: json['duration'] as int)
              : null,
        );

  @override
  Map<String, dynamic>? toJson(MediaItem? item) => item != null
      ? {
          'id': item.id,
          'title': item.title,
          'duration': item.duration?.inMilliseconds
        }
      : null;
}
