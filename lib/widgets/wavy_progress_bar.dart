import 'dart:math';
import 'package:flutter/material.dart';

class WavyProgressBar extends StatefulWidget {
  final double progress;
  final Color waveColor;
  final Color backgroundColor;

  const WavyProgressBar({
    super.key,
    required this.progress,
    this.waveColor = Colors.white,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<WavyProgressBar> createState() => _WavyProgressBarState();
}

class _WavyProgressBarState extends State<WavyProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CustomPaint(
        painter: WavyProgressPainter(
          animation: _controller,
          waveColor: const Color.fromARGB(255, 255, 255, 255),
          progress: widget.progress,
          backgroundColor: widget.backgroundColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class WavyProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final double progress;

  final Color waveColor;
  final Color backgroundColor;

  // Wave configuration
  final int waveCount;
  final double waveAmplitude;

  WavyProgressPainter({
    required this.animation,
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
    this.waveCount = 2,
    this.waveAmplitude = 0.4,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final wavePath = Path();

    wavePath.moveTo(0, size.height);

    final phaseShift = animation.value * 2 * pi;

    final frequency = (2 * pi * waveCount) / size.width;

    for (double x = 0; x <= size.width; x++) {
      final sineY = sin(x * frequency + phaseShift);

      final y = size.height / 2 + sineY * (size.height * waveAmplitude);
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    final progressWidth = size.width * progress.clamp(0.0, 1.0);

    canvas.save();

    canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));

    canvas.drawPath(wavePath, wavePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animation != animation;
  }
}
