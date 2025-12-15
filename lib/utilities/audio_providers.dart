import 'package:music_player/data/position.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final StreamProvider<MediaItem?> mediaItemProvider = StreamProvider<MediaItem?>((ref) => ref.watch(audioHandlerProvider).mediaItem);
final StreamProvider<PositionData> positionProvider = StreamProvider<PositionData>((ref) => ref.watch(audioHandlerProvider).positionDataStream);
final StreamProvider<PlaybackState> playbackStateProvider = StreamProvider<PlaybackState>((ref) => ref.watch(audioHandlerProvider).playbackState);
