import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_player/common/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/providers/setting_switches.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/providers/theme_colors.dart' show playerThemeProvider;

class PermissionErrorPage extends ConsumerWidget {
  const PermissionErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ref.watch(playerThemeProvider),
      locale: ref.watch(currentLocaleProvider),
      localizationsDelegates: const [GeneratedLocalization.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: GeneratedLocalization.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (ctx) {
          final l10n = GeneratedLocalization.of(ctx);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_off, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 20),
                      Text(
                        l10n.permission_required_title,
                        style: const TextStyle(color: Color.fromARGB(255, 171, 35, 35), fontSize: 20),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        l10n.permission_required_body,
                        style: const TextStyle(color: Color.fromARGB(255, 171, 35, 35), fontSize: 16),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () async => await openAppSettings() ? null : ToastManager().showErrorToast(l10n.toast_could_not_open_settings),
                        icon: const Icon(Icons.settings),
                        label: Text(l10n.button_open_settings),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
