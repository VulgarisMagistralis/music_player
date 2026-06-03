import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SettingSwitch extends ConsumerStatefulWidget {
  final String label;
  final ProviderListenable<bool> provider;
  final Future<void> Function(bool value) onToggle;
  const SettingSwitch({super.key, required this.label, required this.provider, required this.onToggle});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsGroupState();
}

class _SettingsGroupState extends ConsumerState<SettingSwitch> {
  @override
  Widget build(BuildContext context) => SizedBox(
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: AnimatedOverflowText(text: widget.label)),
            const SizedBox(width: 10),
            Switch(value: ref.watch(widget.provider), onChanged: widget.onToggle),
          ],
        ),
      ],
    ),
  );
}
