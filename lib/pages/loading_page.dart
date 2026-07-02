import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/utility_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_player/l10n/app_localizations.dart' show GeneratedLocalization;
import 'package:music_player/providers/setting_switches.dart' show currentLocaleProvider;
import 'package:music_player/providers/theme_colors.dart' show primaryAccentColorProvider, primaryTextColorProvider;

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    locale: ref.watch(currentLocaleProvider),
    localizationsDelegates: const [GeneratedLocalization.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Spacer(),
              Image.asset('assets/icons/note_2.png', width: 140),
              const Spacer(),
              CircularProgressIndicator(color: ref.watch(primaryAccentColorProvider)),
              const Spacer(),
              const Spacer(),
              Text(
                ref.watch(localPackageInfoProvider).when(data: (data) => 'Version: $data', error: (_, __) => '', loading: () => 'Reading version information'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: ref.watch(primaryTextColorProvider)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
