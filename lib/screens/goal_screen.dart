import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/exercise_data.dart';
import '../model/exercise_status_provider.dart';
import '../utils/theme_provider.dart';

class GoalScreen extends StatefulWidget {
  final String name;
  final int goal;
  const GoalScreen({super.key, required this.name, required this.goal});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Animated Wavy Background (TOP ONLY)
          SizedBox(
            width: double.infinity,
            height: 320,
            child: AnimatedBuilder(
              key: ValueKey(themeMode), // ensures repaint on theme change
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GoalBgWavesPainter(
                    animationValue: _waveController.value,
                    isDark: isDark,
                  ),
                  size: Size(MediaQuery.of(context).size.width, 320),
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
                const SizedBox(height: 36),
                // Main card content
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
                            color: colorScheme.primary.withOpacity(0.21),
                            width: 1.4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text('${widget.name} Goal',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              )),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.goal} reps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () {
                              try {
                                final completedExercise = Exercise(
                                  name: widget.name,
                                  isTimeBased: false,
                                  totalReps: widget.goal,
                                  totalDuration: Duration.zero,
                                  lastCompleted: DateTime.now(),
                                );
                                Provider.of<ExerciseStatusProvider>(context,
                                        listen: false)
                                    .addCompletedExercise(completedExercise);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Exercise completed and recorded!'),
                                  ),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.sports_gymnastics_outlined),
                            label: const Text(
                              'Complete',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Motivational Quote
                          Text(
                            _motivationalQuotes[
                                widget.goal % _motivationalQuotes.length],
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.secondary.withOpacity(0.82),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Animated Background Painter for GoalScreen (unique style)
class GoalBgWavesPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  GoalBgWavesPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxHeight = size.height;

    // Layer 1: Deep, soft colored wave (diff colors from avatar)
    final Paint paint1 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF181A20),
                const Color(0xFF353B60),
                const Color(0xFF22D4FD),
              ]
            : [
                const Color(0xFFF7F8FA),
                const Color(0xFF72EDF2),
                const Color(0xFF5151E5),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path1 = Path();
    double y1(double x) =>
        maxHeight * 0.56 +
        30 * sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) +
        12 * cos((x / size.width * 2 * pi) + (animationValue * 4 * pi));
    path1.moveTo(0, y1(0));
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(i, y1(i));
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2: Soft accent wave (different accent & opacity)
    final Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF22D4FD).withOpacity(0.35),
                const Color(0xFF353B60).withOpacity(0.26)
              ]
            : [
                const Color(0xFF72EDF2).withOpacity(0.23),
                const Color(0xFF5151E5).withOpacity(0.19)
              ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path2 = Path();
    double y2(double x) =>
        maxHeight * 0.74 +
        14 *
            cos((x / size.width * 2 * pi) + (animationValue * 2 * pi) + pi / 3);
    path2.moveTo(0, y2(0));
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(i, y2(i));
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3: Highlight, more energetic
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
        maxHeight * 0.34 +
        17 * sin((x / size.width * 2 * pi) - (animationValue * 3 * pi)) +
        6 * cos((x / size.width * 2 * pi) + (animationValue * pi));
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
  bool shouldRepaint(covariant GoalBgWavesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isDark != isDark;
}

// Motivational quotes for cycling below the button
const List<String> _motivationalQuotes = [
  "“Push yourself, because no one else is going to do it for you.”",
  "“Strive for progress, not perfection.”",
  "“The only bad workout is the one that didn’t happen.”",
  "“It never gets easier. You just get stronger.”",
  "“One rep at a time. You got this!”",
  "“Great things never come from comfort zones.”",
  "“Your only limit is your mind.”",
  "“Every rep counts. Crush it!”",
];
