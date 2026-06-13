import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/widgets/song_details_panel.dart';
import 'package:music_player/src/rust/api/data/song.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:music_player/utilities/song_row.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final double bottomInset = View.of(context).viewInsets.bottom;
    setState(() => _isKeyboardVisible = bottomInset > 0);
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
    final isAutomotive = ref.watch(isAutomotiveOSProvider).value ?? false;

    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: OrientationBuilder(
        builder: (context, orientation) => LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isWidescreen = maxWidth > 900;
            return SafeArea(
              right: !isAutomotive,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
                child: isWidescreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
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
                                Expanded(child: _buildSearchContent(isSearching, searchResults)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Expanded(child: SongDetailsPanel()),
                                SizedBox(height: 10),
                                NowPlaying(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
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
                          Expanded(child: _buildSearchContent(isSearching, searchResults)),
                          _isKeyboardVisible ? const SizedBox.shrink() : const NowPlaying(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchContent(bool isSearching, AsyncValue<List<Song>>? searchResults) {
    if (!isSearching) {
      return Center(
        child: Text(GeneratedLocalization.of(context).search_placeholder, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    return searchResults!.when(
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
    );
  }
}
