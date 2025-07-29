import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'exercise_data.dart';

class ExerciseStatusProvider extends ChangeNotifier {
  static const String _boxName = 'completed_exercises';
  Box<Exercise>? _exerciseBox;

  bool get isInitialized => _exerciseBox != null && _exerciseBox!.isOpen;

  List<Exercise> get completedExercises =>
      isInitialized ? _exerciseBox!.values.toList() : [];

  /// Call this before using the provider in your app
  Future<void> init() async {
    _exerciseBox = await Hive.openBox<Exercise>(_boxName);
    notifyListeners();
  }

  Future<void> addCompletedExercise(Exercise exercise) async {
    if (!isInitialized) return;
    await _exerciseBox!.add(exercise);
    notifyListeners();
  }

  Future<List<Exercise>> getExercisesByDate(DateTime date) async {
    if (!isInitialized) return [];
    return _exerciseBox!.values
        .where((e) =>
            e.lastCompleted.year == date.year &&
            e.lastCompleted.month == date.month &&
            e.lastCompleted.day == date.day)
        .toList();
  }

  Future<void> clearAll() async {
    if (!isInitialized) return;
    await _exerciseBox!.clear();
    notifyListeners();
  }
}
