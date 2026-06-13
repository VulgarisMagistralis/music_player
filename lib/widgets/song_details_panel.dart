import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/utilities/audio_session_manager.dart';
import 'package:music_player/utilities/providers.dart';

class SongDetailsPanel extends ConsumerWidget {
  const SongDetailsPanel({super.key});

  static String _formatDuration(int? seconds) {
    if (seconds == null) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static Widget _emptyState(BuildContext context) => Center(
    child: Text('No song selected', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final iconTheme = Theme.of(context).iconTheme;

    final BigInt? songIdOrNull = ref.watch(audioSessionManagerProvider.select((s) => s.songId));
    final AsyncValue<Song?> currentSongOrNullAsync = ref.watch(getSongOrNullProvider(songId: songIdOrNull));

    if (songIdOrNull == null) return _emptyState(context);

    return currentSongOrNullAsync.when(
      error: (_, _) => _emptyState(context),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (Song? songOrNull) => songOrNull == null
          ? _emptyState(context)
          : Card(
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(songOrNull.title, style: textTheme.headlineMedium, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(songOrNull.artist, style: textTheme.bodyLarge, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (songOrNull.album.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.album_rounded, size: iconTheme.size ?? 20, color: colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            songOrNull.album,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule_rounded, size: iconTheme.size ?? 20, color: colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 6),
                        Text(_formatDuration(songOrNull.duration), style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
