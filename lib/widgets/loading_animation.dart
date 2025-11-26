import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WaveformLoading extends StatefulWidget {
  const WaveformLoading({super.key});

  @override
  State<WaveformLoading> createState() => _GradientWaveformLoadingState();
}

class _GradientWaveformLoadingState extends State<WaveformLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverflowBox(
    fit: OverflowBoxFit.deferToChild,
    alignment: Alignment.bottomCenter,
    maxWidth: MediaQuery.of(context).size.width + 80,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        willChange: true,
        isComplex: true,
        painter: WavePainter(progress: _controller.value),
        size: const Size(double.infinity, 60),
      ),
    ),
  );
}

class WavePainter extends CustomPainter {
  final double progress;
  final waveHeight = 40.0;
  final speed = 2 * pi;
  WavePainter({required this.progress});
  final gradient = const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4), Color(0xFFFF6B6B)]);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + sin((x / size.width) * speed + (progress * speed)) * waveHeight;
      x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
