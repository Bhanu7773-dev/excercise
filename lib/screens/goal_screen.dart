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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$name Goal: $goal reps',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
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
                  // Save to provider
                  Provider.of<ExerciseStatusProvider>(context, listen: false)
                      .addCompletedExercise(completedExercise);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exercise completed and recorded!'),
                    ),
                  );
                  Navigator.pop(context); // Optionally go back
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
