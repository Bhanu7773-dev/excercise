import 'package:flutter/material.dart';

class StopwatchScreen extends StatelessWidget {
  final String exercise;
  const StopwatchScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Stopwatch for $exercise',
            style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}