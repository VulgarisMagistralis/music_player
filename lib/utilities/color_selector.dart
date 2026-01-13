import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SettingColorSelector extends ConsumerStatefulWidget {
  final String title;
  final ProviderListenable<Color> provider;
  final Future<void> Function(Color newColor) onUpdate;
  const SettingColorSelector({super.key, required this.provider, required this.title, required this.onUpdate});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectorState();
}

class _SelectorState extends ConsumerState<SettingColorSelector> {
  Color invert(Color selectedColor) => Color.from(alpha: 1, red: 1 - selectedColor.r, green: 1 - selectedColor.g, blue: 1 - selectedColor.b);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = ref.watch(widget.provider);
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Text(widget.title),
      onTap: () => ColorPicker(
        pickersEnabled: const {ColorPickerType.wheel: true, ColorPickerType.accent: false, ColorPickerType.primary: false},
        onColorChanged: widget.onUpdate,
        heading: Text(widget.title),
        actionButtons: const ColorPickerActionButtons(dialogActionButtons: false),
        borderColor: invert(selectedColor),
        color: selectedColor,
        wheelHasBorder: true,
        hasBorder: true,
      ).showPickerDialog(context, shadowColor: invert(selectedColor), surfaceTintColor: Colors.black),
    );
  }
}
