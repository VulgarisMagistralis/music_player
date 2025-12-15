import 'dart:math';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  const SeekBar({Key? key, required this.duration, required this.position, required this.bufferedPosition, this.onChanged, this.onChangeEnd}) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  Duration get _remaining => widget.duration - widget.position;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(activeTrackColor: Color.lerp(SliderTheme.of(context).activeTrackColor, Colors.white, .6)),
        child: ExcludeSemantics(
          child: Slider(
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(widget.bufferedPosition.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() => _dragValue = value);
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(inactiveTrackColor: Colors.transparent),
        child: Slider(
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            setState(() => _dragValue = value);
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
      ),
      Positioned(right: 16.0, bottom: 0.0, child: Text(RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch('$_remaining')?.group(1) ?? '$_remaining', style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}
