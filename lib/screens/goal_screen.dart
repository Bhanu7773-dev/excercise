import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/exercise_data.dart';
import '../model/exercise_status_provider.dart';

class GoalScreen extends StatelessWidget {
  final String name;
  final int goal;
  const GoalScreen({super.key, required this.name, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$name Goal: $goal reps',
                style:
                    TextStyle(color: colorScheme.onBackground, fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                try {
                  final completedExercise = Exercise(
                    name: name,
                    isTimeBased: false,
                    totalReps: goal,
                    totalDuration: Duration.zero,
                    lastCompleted: DateTime.now(),
                  );
                  Provider.of<ExerciseStatusProvider>(context, listen: false)
                      .addCompletedExercise(completedExercise);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exercise completed and recorded!'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
