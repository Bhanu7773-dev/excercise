import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../model/exercise_data.dart';
import '../model/exercise_status_provider.dart';
import '../utils/theme_provider.dart'; // Optional, remove if not used

class StopwatchScreen extends StatefulWidget {
  final String exercise;
  const StopwatchScreen({super.key, required this.exercise});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = "00:00";
  late AnimationController _bgWaveController;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          final minutes =
              _stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
          final seconds =
              (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          _elapsedTime = "$minutes:$seconds";
        });
      }
    });
    _bgWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _bgWaveController.dispose();
    super.dispose();
  }

  void _start() => setState(() => _stopwatch.start());
  void _pause() => setState(() => _stopwatch.stop());
  void _reset() {
    setState(() {
      _stopwatch.reset();
      _elapsedTime = "00:00";
    });
  }

  void _complete() {
    if (_stopwatch.elapsed.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please record some time before completing!')),
      );
      return;
    }

    final completedExercise = Exercise(
      name: widget.exercise,
      isTimeBased: true,
      totalReps: 0,
      totalDuration: _stopwatch.elapsed,
      lastCompleted: DateTime.now(),
    );

    Provider.of<ExerciseStatusProvider>(context, listen: false)
        .addCompletedExercise(completedExercise);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time-based exercise recorded!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // For in-app theme support, you can use ThemeProvider or similar if you have it
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Animated Wavy Background (TOP ONLY, but different colors/curves)
          SizedBox(
            width: double.infinity,
            height: 380,
            child: AnimatedBuilder(
              animation: _bgWaveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StopwatchBgWavesPainter(
                    animationValue: _bgWaveController.value,
                    isDark: isDark,
                  ),
                  size: Size(MediaQuery.of(context).size.width, 380),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 10),
                    child: Material(
                      color: isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 22),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.10),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                            color: colorScheme.primary.withOpacity(0.19),
                            width: 1.3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Timer icon with glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        colorScheme.primary.withOpacity(0.18),
                                    blurRadius: 18,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: Icon(Icons.timer_rounded,
                                size: 48, color: colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          Text('${widget.exercise} Timer',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                              )),
                          const SizedBox(height: 10),
                          // Elapsed time, large font
                          Text(
                            _elapsedTime,
                            style: TextStyle(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stopwatch controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StopwatchActionButton(
                                label: 'Start',
                                icon: Icons.play_arrow_rounded,
                                color: colorScheme.secondary,
                                onPressed: _start,
                                textColor: colorScheme.onSecondary,
                              ),
                              const SizedBox(width: 18),
                              _StopwatchActionButton(
                                label: 'Pause',
                                icon: Icons.pause_rounded,
                                color: isDark
                                    ? Colors.grey[800]!
                                    : colorScheme.surfaceVariant,
                                onPressed: _pause,
                                textColor: isDark
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 18),
                              _StopwatchActionButton(
                                label: 'Reset',
                                icon: Icons.replay_rounded,
                                color: isDark
                                    ? Colors.grey[800]!
                                    : colorScheme.surfaceVariant,
                                onPressed: _reset,
                                textColor: isDark
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Complete button
                          ElevatedButton.icon(
                            onPressed: _complete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 34, vertical: 15),
                              elevation: 4,
                            ),
                            icon:
                                const Icon(Icons.check_circle_outline_rounded),
                            label: const Text(
                              'Complete',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Motivational message
                          Text(
                            _stopwatch.elapsed.inSeconds == 0
                                ? "Tap Start to begin your timer!"
                                : "Keep going, every second counts!",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.secondary.withOpacity(0.76),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom wavvy animated background for StopwatchScreen
class StopwatchBgWavesPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  StopwatchBgWavesPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxHeight = size.height;

    // Layer 1: Bright energetic wave
    final Paint paint1 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF232946),
                const Color(0xFF3A86FF),
                const Color(0xFFB5179E),
              ]
            : [
                const Color(0xFFF7F8FA),
                const Color(0xFFA9F1DF),
                const Color(0xFF3A86FF),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path1 = Path();
    double y1(double x) =>
        maxHeight * 0.53 +
        34 * sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) +
        19 * cos((x / size.width * 2 * pi) + (animationValue * 4 * pi));
    path1.moveTo(0, y1(0));
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(i, y1(i));
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2: Subtle secondary wave
    final Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFFB5179E).withOpacity(0.23),
                const Color(0xFF3A86FF).withOpacity(0.19)
              ]
            : [
                const Color(0xFFA9F1DF).withOpacity(0.23),
                const Color(0xFF3A86FF).withOpacity(0.19)
              ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path2 = Path();
    double y2(double x) =>
        maxHeight * 0.75 +
        17 *
            cos((x / size.width * 2 * pi) +
                (animationValue * 2.6 * pi) +
                pi / 3);
    path2.moveTo(0, y2(0));
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(i, y2(i));
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3: Highlight, energetic
    final Paint paint3 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [Colors.white.withOpacity(0.09), Colors.white.withOpacity(0.017)]
            : [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0.035)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path3 = Path();
    double y3(double x) =>
        maxHeight * 0.33 +
        19 * sin((x / size.width * 2 * pi) - (animationValue * 2.7 * pi)) +
        8 * cos((x / size.width * 2 * pi) + (animationValue * 0.8 * pi));
    path3.moveTo(0, y3(0));
    for (double i = 0; i <= size.width; i++) {
      path3.lineTo(i, y3(i));
    }
    path3.lineTo(size.width, 0);
    path3.lineTo(0, 0);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant StopwatchBgWavesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isDark != isDark;
}

// Stopwatch action button used for Start/Pause/Reset
class _StopwatchActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _StopwatchActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      icon: Icon(icon, size: 22),
      label: Text(label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}
