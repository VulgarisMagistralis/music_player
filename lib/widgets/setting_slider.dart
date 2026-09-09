import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/common/animated_overflow_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show ProviderListenable;

class SettingSlider extends ConsumerStatefulWidget {
  final String label;
  final ProviderListenable<int> provider;
  final Future<void> Function(int value) onUpdate;
  final int minValue;
  final int maxValue;

  const SettingSlider({super.key, required this.label, required this.provider, required this.onUpdate, this.minValue = 0, this.maxValue = 255});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingSliderState();
}

class _SettingSliderState extends ConsumerState<SettingSlider> {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    child: Row(
      children: [
        Expanded(child: AnimatedOverflowText(text: widget.label)),
        const SizedBox(width: 6),
        Flexible(
          flex: 2,
          child: Slider(
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            value: ref.watch(widget.provider).toDouble().clamp(widget.minValue.toDouble(), widget.maxValue.toDouble()),
            onChanged: (value) => widget.onUpdate(value.round()),
          ),
        ),
        SizedBox(width: 40, child: Text(ref.watch(widget.provider).toString(), textAlign: TextAlign.end)),
      ],
    ),
  );
}
