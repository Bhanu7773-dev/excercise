import 'package:flutter/foundation.dart';
import 'exercise_data.dart';

class ExerciseStatusProvider extends ChangeNotifier {
  final List<Exercise> _completedExercises = [];

  List<Exercise> get completedExercises =>
      List.unmodifiable(_completedExercises);

  void addCompletedExercise(Exercise exercise) {
    _completedExercises.add(exercise);
    notifyListeners();
  }

  Future<List<Exercise>> getExercisesByDate(DateTime date) async {
    return _completedExercises
        .where((e) =>
            e.lastCompleted.year == date.year &&
            e.lastCompleted.month == date.month &&
            e.lastCompleted.day == date.day)
        .toList();
  }

  void clearAll() {
    _completedExercises.clear();
    notifyListeners();
  }
}
