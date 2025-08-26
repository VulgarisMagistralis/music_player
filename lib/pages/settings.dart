import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/data/theme_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/theme/theme_providers.dart';
import 'package:music_player/utilities/settings_data.dart';
import 'package:music_player/utilities/color_selector.dart';
import 'package:music_player/utilities/string_extension.dart';

/// Loaded saved folders, enable ordering , delete/add
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  List<String> libraryPathList = [];

  @override
  void initState() {
    super.initState();
    libraryPathList = SharedPreferenceWithCacheHandler.instance.getMusicFolderList();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _pickDirectory(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.isNotEmpty) {
      if (!libraryPathList.contains(result)) await SharedPreferenceWithCacheHandler.instance.saveMusicFolderList(libraryPathList + [result]);
      setState(() => libraryPathList = SharedPreferenceWithCacheHandler.instance.getMusicFolderList());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(children: [
                Row(children: [const PlayerHeader(), IconButton(icon: const Icon(Icons.file_download), onPressed: () => _pickDirectory(context))]),
                const Text('FOLDERS'),
                Column(children: libraryPathList.map((e) => Text(e.beautifyFolderPath(), style: const TextStyle(color: Colors.black))).toList()),
                ColorSelector(provider: basicColorProvider(ThemeKeys.mainBackgroundColor), title: 'Background Color'),
                ColorSelector(provider: basicColorProvider(ThemeKeys.primaryTextColor), title: 'Main Text Color')
              ]))));
}
