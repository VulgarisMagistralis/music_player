// tool/build/locale_generator_builder.dart
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'dart:async';

Builder localeGeneratorBuilder(BuilderOptions options) {
  return LocaleGeneratorBuilder();
}

class LocaleGeneratorBuilder implements Builder {
  @override
  Future<void> build(BuildStep buildStep) async {
    // Only run once by checking a specific input
    final inputId = buildStep.inputId;
    if (inputId.path != 'pubspec.yaml') {
      return;
    }

    // Find all .arb files in lib/l10n/
    final arbAssets = <String>[];

    await for (final asset in buildStep.findAssets(Glob('lib/l10n/app_*.arb'))) {
      arbAssets.add(asset.path);
      print('Found ARB file: ${asset.path}');
    }

    if (arbAssets.isEmpty) {
      print('No ARB files found!');
      return;
    }

    // Extract locales from filenames: app_en.arb → 'en'
    final locales = <String>[];
    for (final path in arbAssets) {
      final fileName = path.split('/').last; // app_en.arb
      final locale = fileName.replaceAll('app_', '').replaceAll('.arb', '');
      locales.add(locale);
      print('Extracted locale: $locale');
    }

    // Sort for consistency
    locales.sort();

    // Generate the output file
    final generatedCode = _generateCode(locales);

    final outputId = AssetId(buildStep.inputId.package, 'lib/generated/supported_locales.g.dart');

    print('Writing to: ${outputId.path}');
    await buildStep.writeAsString(outputId, generatedCode);
  }

  String _generateCode(List<String> locales) {
    final localeLines = locales
        .map((locale) {
          final parts = locale.split('_');
          if (parts.length == 1) {
            return "  Locale('${parts[0]}')";
          } else {
            return "  Locale('${parts[0]}', '${parts[1]}')";
          }
        })
        .toList()
        .join(',\n');

    return '''// GENERATED FILE - DO NOT EDIT
// Auto-generated from ARB files in lib/l10n/
// Run: flutter pub run build_runner build

import 'package:flutter/material.dart';

const List<Locale> supportedLocales = [
$localeLines
];
''';
  }

  @override
  final buildExtensions = {
    'pubspec.yaml': ['lib/generated/supported_locales.g.dart'],
  };
}
