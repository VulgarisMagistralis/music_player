import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

/// Bridges playback state into the Android home-screen widget.
///
/// The Android side (MusicWidgetProvider) reads from the SharedPreferences written by
/// MainActivity's "com.cenkt.music_player/widget" MethodChannel. Every push here re-renders
/// the widget immediately, so the home-screen tile always matches what's playing in the app.
class WidgetBridge {
  const WidgetBridge._();

  static const _channel = MethodChannel('com.cenkt.music_player/widget');

  /// Push the current playback state to the widget.
  /// No-ops on non-Android platforms. Safe to call during hot-reload / tests.
  static void push({
    required MediaItem? item,
    required bool isPlaying,
    String? playlist,
    int? positionMs,
    int? durationMs,
  }) {
    if (!Platform.isAndroid) return;
    final args = <String, dynamic>{
      'title': (item?.title ?? '').toString(),
      'artist': (item?.artist ?? '').toString(),
      // artUri is a content:// URI served by the app's FileProvider; the widget provider
      // runs in the app process and can read its own FileProvider via context.contentResolver.
      'album_art': item?.artUri?.toString() ?? '',
      'is_playing': isPlaying,
      'has_item': item != null,
      'playlist': playlist ?? '',
      'position_ms': positionMs ?? 0,
      'duration_ms': durationMs ?? 0,
    };
    _channel
        .invokeMethod<bool>('updateWidget', args)
        .catchError((Object? _) => false);
  }
}
