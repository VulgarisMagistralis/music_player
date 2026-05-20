import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show ProviderListenable;

class SettingDropdownSelector<T> extends ConsumerWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ProviderListenable<T> provider;
  final Future<void> Function(T) onSelect;

  const SettingDropdownSelector({
    super.key,
    required this.label,
    required this.items,
    required this.provider,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(provider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: AnimatedOverflowText(text: label)),
          const SizedBox(width: 10),
          DropdownButton<T>(
            value: selected,
            items: items,
            onChanged: (value) {
              if (value != null) onSelect(value);
            },
          ),
        ],
      ),
    );
  }
}
