import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/providers/theme_colors.dart';
import 'package:music_player/widgets/setting_number.dart';
import 'package:music_player/widgets/setting_switch.dart';
import 'package:music_player/utilities/color_selector.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/utilities/string_extension.dart';
import 'package:music_player/providers/utility_providers.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/low_level_wrapper/init.dart' show LowLevelInitializer;

/// Loaded saved folders, enable ordering , delete/add
/// show/hide icon for songs without album art
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _pickDirectory(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.isNotEmpty) {
      final List<String> libraryPathList = await ref.read(loadLibraryProvider.future);
      if (!libraryPathList.contains(result)) {
        await ref.read(saveLibraryProvider(libraryPathList + [result]).future);
        ref.invalidate(loadLibraryProvider);
        ref.invalidate(processMusicFilesProvider);
        ref.invalidate(allSongsProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadedLibraryList = ref.watch(loadLibraryProvider);
    return Scaffold(
      bottomNavigationBar: const PlayerNavigationBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlayerHeader(),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Center(child: Text('Source')),
                    ExpansionTile(
                      title: Row(
                        children: [
                          const Text('Folders'),
                          const SizedBox(width: 20),
                          loadedLibraryList.when(
                            data: (libraryPathList) => libraryPathList.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    width: 18,
                                    height: 18,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                    child: Text(
                                      libraryPathList.length.toString(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                  ),
                            error: (error, stackTrace) {
                              WidgetsBinding.instance.addPostFrameCallback((_) async {
                                await LowLevelInitializer.init();
                                ref.invalidate(loadLibraryProvider);
                              });
                              ToastManager().showErrorToast('Encountered loading error from this folder. Reloading...');
                              return const SizedBox.shrink();
                            },
                            loading: () => const CircularProgressIndicator(),
                          ),
                        ],
                      ),
                      trailing: GestureDetector(child: const Icon(Icons.add_circle_outline), onTap: () => _pickDirectory(context)),
                      children: loadedLibraryList.when(
                        data: (List<String> libraryPathList) => libraryPathList
                            .map(
                              (libraryPath) => ListTile(
                                title: AnimatedOverflowText(text: libraryPath.beautifyFolderPath()),
                                trailing: GestureDetector(
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    shadows: [Shadow(blurRadius: 4, offset: Offset(1, 1))],
                                    color: Colors.red,
                                  ),
                                  onTap: () async {
                                    await ref.read(deleteLibraryProvider(libraryPath).future);
                                    ref.invalidate(loadLibraryProvider);
                                    ref.invalidate(processMusicFilesProvider);
                                    ref.invalidate(allSongsProvider);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                        error: (error, stackTrace) {
                          ref.invalidate(loadLibraryProvider);
                          return [const Text('ERROR!')];
                        },
                        loading: () => [Text('Trying to read folder')],
                      ),
                    ),
                    const Divider(),
                    const Center(child: Text('Theme')),
                    SettingColorSelector(title: 'Background Color', provider: primaryBackgroundColorProvider, onUpdate: ref.read(primaryBackgroundColorProvider.notifier).update),
                    SettingColorSelector(title: 'Main Text Color', provider: primaryTextColorProvider, onUpdate: ref.read(primaryTextColorProvider.notifier).update),
                    SettingColorSelector(title: 'Accent Color', provider: primaryAccentColorProvider, onUpdate: ref.read(primaryAccentColorProvider.notifier).update),
                    SettingNumberSelector(label: 'Font Size', provider: fontSizeAdjustmentProvider, onUpdate: ref.read(fontSizeAdjustmentProvider.notifier).update),
                    SettingNumberSelector(label: 'Icon Size', provider: iconSizeAdjustmentProvider, onUpdate: ref.read(iconSizeAdjustmentProvider.notifier).update),
                    SettingSwitch(label: 'Show song icons on lists', provider: showSongIconProvider, onToggle: ref.read(showSongIconProvider.notifier).setFlag),
                    const Divider(),
                    const Center(child: Text('Behaviour')),
                    SettingSwitch(label: 'Play on launch', provider: playOnLaunchProvider, onToggle: ref.read(playOnLaunchProvider.notifier).setFlag),
                    SettingSwitch(label: 'Play when connected', provider: playOnConnectProvider, onToggle: ref.read(playOnConnectProvider.notifier).setFlag),
                    SettingSwitch(label: 'Pause when muted', provider: pauseWhenMutedProvider, onToggle: ref.read(pauseWhenMutedProvider.notifier).setFlag),
                    SettingSwitch(label: 'Pause when hidden', provider: pauseOnHiddenProvider, onToggle: ref.read(pauseOnHiddenProvider.notifier).setFlag),
                    SettingSwitch(label: 'Resume after disconnected', provider: resumeAfterDisconnectProvider, onToggle: ref.read(resumeAfterDisconnectProvider.notifier).setFlag),
                    SettingSwitch(label: 'Show navigation buttons', provider: showAndroidNavigationButtonsProvider, onToggle: ref.read(showAndroidNavigationButtonsProvider.notifier).setFlag),
                    SettingNumberSelector(label: 'Rewind Interval', provider: rewindIntervalInSecondsProvider, onUpdate: ref.read(rewindIntervalInSecondsProvider.notifier).update),
                    SettingNumberSelector(label: 'Fast Forward Interval', provider: fastForwardIntervalInSecondsProvider, onUpdate: ref.read(fastForwardIntervalInSecondsProvider.notifier).update),

                    ///TODO Locale
                    /// Ignore media less than X seconds
                    /// toggle persistent player across pages
                    /// confirm deletion of playlists
                    Row(
                      children: [
                        const Text('Version'),
                        ref.watch(storeVersionInfoProvider).when(data: (storeVersion) => Text(storeVersion ?? ''), error: (_, __) => const SizedBox.shrink(), loading: () => const SizedBox.shrink()),
                        const Spacer(),
                        Text(ref.watch(localPackageInfoProvider).when(data: (data) => data, error: (_, __) => '', loading: () => 'still loading')),
                      ],
                    ),
                  ],
                ),
              ),
              const NowPlaying(),
            ],
          ),
        ),
      ),
    );
  }
}
