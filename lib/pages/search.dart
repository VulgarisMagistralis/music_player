import 'package:flutter/material.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/header.dart';

/// Determine app state and reroute
/// check file read permission
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
      bottomNavigationBar: PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 10, 0),
        child: Column(
          children: [
            PlayerHeader(),
          ],
        ),
      )));
}
