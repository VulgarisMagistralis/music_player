import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/utilities/song_row.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _currentQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _currentQuery.trim().isNotEmpty;
    final searchResults = isSearching ? ref.watch(searchSongsProvider(query: _currentQuery)) : null;

    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            children: [
              const PlayerHeader(),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: GeneratedLocalization.of(context).search_hint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _currentQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (!isSearching)
                Expanded(
                  child: Center(
                    child: Text(GeneratedLocalization.of(context).search_placeholder, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                )
              else
                Expanded(
                  child: searchResults!.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(GeneratedLocalization.of(context).search_error, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    data: (songs) {
                      if (songs.isEmpty) {
                        return Center(
                          child: Text(GeneratedLocalization.of(context).search_no_results, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        );
                      }
                      return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return SongRow(
                            song: song,
                            index: index,
                            onTap: (int idx) async {
                              await ref.read(audioHandlerSyncProvider).setPlaylist('search', songs, index: idx);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
