import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show ProviderListenable;

class SettingNumberSelector extends ConsumerStatefulWidget {
  final String label;
  final ProviderListenable<int> provider;
  final Future<void> Function(int) onUpdate;
  const SettingNumberSelector({super.key, required this.label, required this.onUpdate, required this.provider});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingNumberSelectorState();
}

class _SettingNumberSelectorState extends ConsumerState<SettingNumberSelector> {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(widget.label),
      const Spacer(),
      IconButton(icon: const Icon(Icons.remove), onPressed: () => widget.onUpdate(-1)),
      Text(ref.watch(widget.provider).toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      IconButton(icon: const Icon(Icons.add), onPressed: () => widget.onUpdate(1)),
    ],
  );
}
