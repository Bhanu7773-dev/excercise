import 'dart:math';
import 'package:flutter/material.dart';

class WavyProgressBar extends StatefulWidget {
  final double progress;
  final Color waveColor;
  final Color backgroundColor;
  final Color indicatorColor;

  const WavyProgressBar({
    super.key,
    required this.progress,
    this.waveColor = Colors.white,
    this.backgroundColor = Colors.grey,
    this.indicatorColor = Colors.white,
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
      duration: const Duration(milliseconds: 2500), // Slower for a smoother wave
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enforce a constant height to accommodate the circle's diameter.
    return SizedBox(
      height: 10.0,
      child: CustomPaint(
        painter: SlimWaveProgressPainter(
          animation: _controller,
          progress: widget.progress,
          waveColor: widget.waveColor,
          backgroundColor: widget.backgroundColor,
          indicatorColor: widget.indicatorColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class SlimWaveProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final double progress;
  final Color waveColor;
  final Color backgroundColor;
  final Color indicatorColor;

  // Wave configuration
  final double waveAmplitude;
  final double waveFrequency;

  SlimWaveProgressPainter({
    required this.animation,
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
    required this.indicatorColor,
    this.waveAmplitude = 2.0, // Amplitude of the wave (pixels)
    this.waveFrequency = 0.12, // Increased frequency for more waves
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerY = size.height / 2;
    final progressWidth = size.width * progress.clamp(0.0, 1.0);

    // --- 1. Paint for the background (remaining progress) ---
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the straight line for the remaining part
    canvas.drawLine(
      Offset(progressWidth, centerY),
      Offset(size.width, centerY),
      backgroundPaint,
    );

    // --- 2. Paint and Path for the animated wave (completed progress) ---
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 // Slightly thicker to stand out
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    wavePath.moveTo(0, centerY);

    final phaseShift = animation.value * 2 * pi;

    for (double x = 0; x <= progressWidth; x++) {
      final sineY = sin(x * waveFrequency + phaseShift) * waveAmplitude;
      wavePath.lineTo(x, centerY + sineY);
    }

    // Draw the wave path
    canvas.drawPath(wavePath, wavePaint);

    // --- 3. Paint for the circle indicator ---
    final indicatorPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    // Draw the circle at the exact progress position with a radius of 5 (for a 10 diameter)
    canvas.drawCircle(
      Offset(progressWidth, centerY),
      5.0,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SlimWaveProgressPainter oldDelegate) {
    // Repaint if any of the visual properties change
    return oldDelegate.progress != progress ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.indicatorColor != indicatorColor ||
        oldDelegate.animation != animation;
  }
}
