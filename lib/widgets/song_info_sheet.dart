import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/widgets/album_art_widget.dart';
import 'package:music_player/utilities/providers.dart';

class SongInfoSheet extends ConsumerWidget {
  final Song song;

  const SongInfoSheet({super.key, required this.song});

  static void show(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SongInfoSheet(song: song),
    );
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.shade500, borderRadius: BorderRadius.circular(2)),
            ),
            AlbumArtWidget(songId: song.id, width: 200),
            const SizedBox(height: 20),
            Text(
              song.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              song.artist,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (song.album.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.album, size: 20),
                  const SizedBox(width: 6),
                  Text(song.album, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(_formatDuration(song.duration)),
                const SizedBox(width: 16),
                const Icon(Icons.update, size: 18),
                const SizedBox(width: 6),
                Text(song.lastModifiedAt.toString(), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(audioHandlerSyncProvider).setPlaylist('song info', [song], index: 0);
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(GeneratedLocalization.of(context).button_play),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
