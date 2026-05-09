import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/generated/supported_locales.g.dart' show supportedLocales;
import 'package:music_player/providers/setting_switches.dart' show currentLocaleProvider;

class SettingLocaleSelector extends ConsumerWidget {
  final String label;

  const SettingLocaleSelector({super.key, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);

    return Column(
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            DropdownMenu(
              showTrailingIcon: false,
              textAlign: TextAlign.end,
              selectOnly: true,
              scrollPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              alignmentOffset: const Offset(-10, 0),
              initialSelection: currentLocale,
              dropdownMenuEntries: supportedLocales
                  .map(
                    (locale) => DropdownMenuEntry(
                      value: locale,
                      label: _languageName(locale.languageCode),
                      labelWidget: Row(
                        children: [
                          CountryFlag.fromLanguageCode(locale.languageCode, theme: const ImageTheme(width: 25, height: 25, shape: Circle())),
                          const SizedBox(width: 10),
                          Text(locale.countryCode != null ? _languageName(locale.languageCode) : _languageName(locale.languageCode), style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onSelected: (locale) {
                if (locale != null) {
                  ref.read(currentLocaleProvider.notifier).setLocale(locale);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  static String _languageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      default:
        return code;
    }
  }
}
