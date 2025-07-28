import 'package:flutter/material.dart'; // Only needed if you use Color or other Flutter types
// Remove provider import: no need for providers in your model

class Exercise {
  final String name;
  final bool isTimeBased;
  final int totalReps;
  final Duration totalDuration;
  final DateTime lastCompleted;

  Exercise({
    required this.name,
    required this.isTimeBased,
    this.totalReps = 0,
    this.totalDuration = Duration.zero,
    required this.lastCompleted,
  });
}
