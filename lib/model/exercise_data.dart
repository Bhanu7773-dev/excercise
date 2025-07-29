import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'exercise_data.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final bool isTimeBased;

  @HiveField(2)
  final int totalReps;

  // Duration cannot be stored directly, so store in seconds
  @HiveField(3)
  final int totalDurationSeconds;

  @HiveField(4)
  final DateTime lastCompleted;

  Exercise({
    required this.name,
    required this.isTimeBased,
    this.totalReps = 0,
    Duration totalDuration = Duration.zero,
    required this.lastCompleted,
  }) : totalDurationSeconds = totalDuration.inSeconds;

  Duration get totalDuration => Duration(seconds: totalDurationSeconds);
}
