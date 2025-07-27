import 'package:flutter/material.dart';

class GoalScreen extends StatelessWidget {
  final String name;
  final int goal;
  const GoalScreen({super.key, required this.name, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('$name Goal: $goal reps',
            style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}
