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
import 'package:music_player/common/animated_overflow_text.dart';

/// Loaded saved folders, enable ordering , delete/add
/// show/hide icon for songs without album art
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
              padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PlayerHeader(),
                ExpansionTile(
                    title: Row(children: [
                      const Text('Folders'),
                      const SizedBox(width: 20),
                      if (libraryPathList.isNotEmpty)
                        Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                            child: Text(libraryPathList.length.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)))
                    ]),
                    trailing: GestureDetector(child: const Icon(Icons.add_circle_outline), onTap: () => _pickDirectory(context)),
                    children: libraryPathList
                        .map((libraryPath) => ListTile(
                            title: AnimatedOverflowText(text: libraryPath.beautifyFolderPath()),
                            trailing: GestureDetector(
                                child: const Icon(Icons.remove_circle_outline, shadows: [Shadow(blurRadius: 4, offset: Offset(1, 1))], color: Colors.red),
                                onTap: () async {
                                  libraryPathList.remove(libraryPath);
                                  await SharedPreferenceWithCacheHandler.instance.saveMusicFolderList(libraryPathList);
                                  setState(() {});
                                })))
                        .toList()),
                ColorSelector(provider: basicColorProvider(ThemeKeys.mainBackgroundColor), title: 'Background Color'),
                ColorSelector(provider: basicColorProvider(ThemeKeys.primaryTextColor), title: 'Main Text Color'),
                // ToggleButtons(isSelected: const [
                //   false
                // ], children: const [
                //   Text('Show system navigation buttons'),
                // ])
              ]))));
}
