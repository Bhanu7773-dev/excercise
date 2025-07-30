import 'dart:math';
import 'package:flutter/material.dart';

class WavyProgressBar extends StatefulWidget {
  final double progress;
  final Color waveColor;
  final Color backgroundColor;
  final Color indicatorColor;
  // Callbacks to handle user seeking
  final VoidCallback? onSeekStart;
  final ValueChanged<double>? onSeek;
  final ValueChanged<double>? onSeekEnd;

  const WavyProgressBar({
    super.key,
    required this.progress,
    this.waveColor = Colors.white,
    this.backgroundColor = Colors.grey,
    this.indicatorColor = Colors.white,
    this.onSeekStart,
    this.onSeek,
    this.onSeekEnd,
  });

  @override
  State<WavyProgressBar> createState() => _WavyProgressBarState();
}

class _WavyProgressBarState extends State<WavyProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDragging = false;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDragPosition(Offset localPosition, BoxConstraints constraints) {
    final newProgress = (localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    setState(() {
      _dragProgress = newProgress;
    });
    widget.onSeek?.call(newProgress);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragStart: (details) {
            // Check if the drag starts near the indicator circle
            final currentIndicatorX = widget.progress * constraints.maxWidth;
            final startX = details.localPosition.dx;
            // Define a touch target area around the indicator
            const touchSlop = 24.0; 
            if ((startX - currentIndicatorX).abs() < touchSlop) {
              setState(() {
                _isDragging = true;
                _dragProgress = widget.progress;
              });
              widget.onSeekStart?.call();
              _updateDragPosition(details.localPosition, constraints);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (_isDragging) {
              _updateDragPosition(details.localPosition, constraints);
            }
          },
          onHorizontalDragEnd: (details) {
            if (_isDragging) {
              widget.onSeekEnd?.call(_dragProgress);
              setState(() {
                _isDragging = false;
              });
            }
          },
          child: SizedBox(
            height: 10.0,
            width: double.infinity,
            child: CustomPaint(
              painter: SlimWaveProgressPainter(
                animation: _controller,
                // Use drag progress if dragging, otherwise use widget progress
                progress: _isDragging ? _dragProgress : widget.progress,
                isDragging: _isDragging,
                waveColor: widget.waveColor,
                backgroundColor: widget.backgroundColor,
                indicatorColor: widget.indicatorColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SlimWaveProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final double progress;
  final bool isDragging;
  final Color waveColor;
  final Color backgroundColor;
  final Color indicatorColor;

  // Wave configuration
  final double waveAmplitude;
  final double waveFrequency;

  SlimWaveProgressPainter({
    required this.animation,
    required this.progress,
    required this.isDragging,
    required this.waveColor,
    required this.backgroundColor,
    required this.indicatorColor,
    this.waveAmplitude = 2.0,
    this.waveFrequency = 0.12,
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

    canvas.drawLine(
      Offset(progressWidth, centerY),
      Offset(size.width, centerY),
      backgroundPaint,
    );

    // --- 2. Paint and Path for the animated wave (completed progress) ---
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    wavePath.moveTo(0, centerY);

    final phaseShift = animation.value * 2 * pi;

    for (double x = 0; x <= progressWidth; x++) {
      final sineY = sin(x * waveFrequency + phaseShift) * waveAmplitude;
      wavePath.lineTo(x, centerY + sineY);
    }

    canvas.drawPath(wavePath, wavePaint);

    // --- 3. Paint for the circle indicator ---
    final indicatorPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;
      
    // Make the circle slightly larger when dragging for visual feedback
    final indicatorRadius = isDragging ? 7.0 : 5.0;

    canvas.drawCircle(
      Offset(progressWidth, centerY),
      indicatorRadius,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SlimWaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.indicatorColor != indicatorColor ||
        oldDelegate.animation != animation;
  }
}
