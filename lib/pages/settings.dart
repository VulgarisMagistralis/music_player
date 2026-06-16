import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_player/common/toast.dart';
import 'package:music_player/menu/nav_bar.dart';
import 'package:music_player/widgets/header.dart';
import 'package:music_player/widgets/song_card.dart';
import 'package:music_player/widgets/song_details_panel.dart';
import 'package:music_player/utilities/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/ui_elements.dart';
import 'package:music_player/providers/theme_colors.dart';
import 'package:music_player/widgets/setting_number.dart';
import 'package:music_player/widgets/setting_switch.dart';
import 'package:music_player/widgets/setting_locale_selector.dart';
import 'package:music_player/widgets/setting_dropdown_selector.dart';
import 'package:music_player/utilities/color_selector.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:music_player/utilities/string_extension.dart';
import 'package:music_player/providers/utility_providers.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:music_player/low_level_wrapper/init.dart' show LowLevelInitializer;
import 'package:music_player/l10n/app_localizations.dart';

/// Loaded saved folders, enable ordering , delete/add
/// show/hide icon for songs without album art
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _pickDirectory(BuildContext context) async {
    final result = await FilePicker.getDirectoryPath();
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

  Widget _buildSettingsContent(AsyncValue<List<String>> loadedLibraryList) {
    return ListView(
      shrinkWrap: true,
      children: [
        Center(child: Text(GeneratedLocalization.of(context).settings_page_title)),
        ExpansionTile(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(GeneratedLocalization.of(context).settings_folder_title),
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
                  ToastManager().showErrorToast(GeneratedLocalization.of(context).toast_folder_load_error);
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
                      child: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
              return [Text(GeneratedLocalization.of(context).settings_folder_error)];
            },
            loading: () => [Text(GeneratedLocalization.of(context).settings_folder_loading)],
          ),
        ),
        const Divider(),
        Center(child: Text(GeneratedLocalization.of(context).settings_appearance_title)),
        SettingColorSelector(title: GeneratedLocalization.of(context).settings_appearance_background_color, provider: primaryBackgroundColorProvider, onUpdate: ref.read(primaryBackgroundColorProvider.notifier).update),
        //needs label clip
        SettingColorSelector(title: GeneratedLocalization.of(context).settings_appearance_main_text_color, provider: primaryTextColorProvider, onUpdate: ref.read(primaryTextColorProvider.notifier).update),
        SettingColorSelector(title: GeneratedLocalization.of(context).settings_appearance_accent_color, provider: primaryAccentColorProvider, onUpdate: ref.read(primaryAccentColorProvider.notifier).update),
        SettingNumberSelector(label: GeneratedLocalization.of(context).settings_appearance_font_size, provider: fontSizeAdjustmentProvider, onUpdate: ref.read(fontSizeAdjustmentProvider.notifier).update),
        SettingNumberSelector(label: GeneratedLocalization.of(context).settings_appearance_icon_size, provider: iconSizeAdjustmentProvider, onUpdate: ref.read(iconSizeAdjustmentProvider.notifier).update),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_show_song_icons, provider: showSongIconProvider, onToggle: ref.read(showSongIconProvider.notifier).setFlag),
        const Divider(),
        Center(child: Text(GeneratedLocalization.of(context).settings_behaviour_title)),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_play_on_launch, provider: playOnLaunchProvider, onToggle: ref.read(playOnLaunchProvider.notifier).setFlag),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_play_on_connect, provider: playOnConnectProvider, onToggle: ref.read(playOnConnectProvider.notifier).setFlag),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_pause_when_muted, provider: pauseWhenMutedProvider, onToggle: ref.read(pauseWhenMutedProvider.notifier).setFlag),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_pause_when_hidden, provider: pauseOnHiddenProvider, onToggle: ref.read(pauseOnHiddenProvider.notifier).setFlag),
        SettingSwitch(label: GeneratedLocalization.of(context).settings_behaviour_resume_after_disconnect, provider: resumeAfterDisconnectProvider, onToggle: ref.read(resumeAfterDisconnectProvider.notifier).setFlag),
        SettingSwitch(
          label: GeneratedLocalization.of(context).settings_behaviour_show_nav_buttons,
          provider: showAndroidNavigationButtonsProvider,
          onToggle: ref.read(showAndroidNavigationButtonsProvider.notifier).setFlag,
        ),
        SettingDropdownSelector<int>(
          label: GeneratedLocalization.of(context).settings_playback_rewind_interval,
          provider: rewindIntervalInSecondsProvider,
          items: const [1, 2, 3, 5, 10].map((v) => DropdownMenuItem<int>(value: v, child: Text('$v s'))).toList(),
          onSelect: ref.read(rewindIntervalInSecondsProvider.notifier).update,
        ),
        SettingDropdownSelector<int>(
          label: GeneratedLocalization.of(context).settings_playback_fast_forward_interval,
          provider: fastForwardIntervalInSecondsProvider,
          items: const [1, 2, 3, 5, 10].map((v) => DropdownMenuItem<int>(value: v, child: Text('$v s'))).toList(),
          onSelect: ref.read(fastForwardIntervalInSecondsProvider.notifier).update,
        ),
        SettingDropdownSelector<int>(
          label: GeneratedLocalization.of(context).settings_behaviour_ignored_duration_threshold,
          provider: ignoredDurationThresholdProvider,
          items: const [0, 15, 30, 60, 120].map((v) => DropdownMenuItem<int>(value: v, child: Text(v == 0 ? 'Off' : '$v s'))).toList(),
          onSelect: ref.read(ignoredDurationThresholdProvider.notifier).update,
        ),
        SettingLocaleSelector(label: GeneratedLocalization.of(context).settings_appearance_language),

        /// Ignore media less than X seconds
        /// toggle persistent player across pages
        /// confirm deletion of playlists
        const SizedBox(height: 10),
        Row(
          children: [Text(ref.watch(localPackageInfoProvider).when(data: (data) => data, error: (_, __) => '', loading: () => GeneratedLocalization.of(context).loading_still_loading))],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAutomotive = ref.watch(isAutomotiveOSProvider).value ?? false;
    final loadedLibraryList = ref.watch(loadLibraryProvider);
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const PlayerHeader(),
                                Expanded(child: _buildSettingsContent(loadedLibraryList)),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PlayerHeader(),
                          Expanded(child: _buildSettingsContent(loadedLibraryList)),
                          const NowPlaying(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
