import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Text(widget.label),
          const Spacer(),
          Switch(value: ref.watch(widget.provider), onChanged: widget.onToggle),
        ],
      ),
    ],
  );
}
