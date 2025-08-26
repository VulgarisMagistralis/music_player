import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/theme/theme_providers.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ColorSelector extends ConsumerStatefulWidget {
  final String title;
  final BasicColorProvider provider;
  ColorSelector({required this.provider, required this.title});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectorState();
}

class _SelectorState extends ConsumerState<ColorSelector> {
  Color invert(Color selectedColor) => Color.from(alpha: 1, red: 1 - selectedColor.r, green: 1 - selectedColor.g, blue: 1 - selectedColor.b);

  @override
  Widget build(BuildContext context) {
    Color selectedColor = ref.watch(widget.provider);
    return ListTile(
        title: Text(widget.title),
        onTap: () => ColorPicker(
                pickersEnabled: {ColorPickerType.wheel: true, ColorPickerType.accent: false, ColorPickerType.primary: false},
                onColorChanged: (Color color) => ref.read(widget.provider.notifier).update(color),
                heading: Text(widget.title),
                actionButtons: ColorPickerActionButtons(dialogActionButtons: false),
                borderColor: invert(selectedColor),
                color: selectedColor,
                wheelHasBorder: true,
                hasBorder: true)
            .showPickerDialog(context, shadowColor: invert(selectedColor), surfaceTintColor: Colors.black));
  }
}
