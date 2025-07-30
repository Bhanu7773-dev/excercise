import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../screens/goal_screen.dart';
import '../screens/stopwatch_screen.dart';

class ExerciseList extends StatefulWidget {
  final List<String> goalExercises;
  final List<String> stopwatchExercises;
  final Map<String, int> exerciseGoals;
  final void Function(String) onEditGoal;
  final IconData Function(String) getExerciseIcon;

  const ExerciseList({
    Key? key,
    required this.goalExercises,
    required this.stopwatchExercises,
    required this.exerciseGoals,
    required this.onEditGoal,
    required this.getExerciseIcon,
  }) : super(key: key);

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  bool _isSearching = false;
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercises = [...widget.goalExercises, ...widget.stopwatchExercises];
    final filteredExercises = _searchText.isEmpty
        ? exercises
        : exercises
            .where((e) => e.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();

    return Column(
      children: [
        _buildWorkoutLibrary(context),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final name = filteredExercises[index];
              final isGoal = widget.goalExercises.contains(name);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: ListTile(
                  minVerticalPadding: 18,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 18),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isGoal
                          ? colorScheme.primary.withOpacity(0.13)
                          : colorScheme.secondary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.getExerciseIcon(name),
                      color: isGoal ? colorScheme.primary : colorScheme.secondary,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isGoal
                        ? "Goal: ${widget.exerciseGoals[name]} reps"
                        : "Time-based exercise",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: isGoal
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Iconsax.edit_2,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                onPressed: () => widget.onEditGoal(name),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Iconsax.play, size: 22),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GoalScreen(
                                      name: name,
                                      goal: widget.exerciseGoals[name]!,
                                    ),
                                  ),
                                ),
                                color: colorScheme.onPrimary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Iconsax.play, size: 22),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StopwatchScreen(exercise: name),
                              ),
                            ),
                            color: colorScheme.secondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutLibrary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workout Library",
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${widget.goalExercises.length + widget.stopwatchExercises.length} exercises",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _isSearching
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: (val) => setState(() => _searchText = val),
                      style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Search exercises...",
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, size: 18, color: colorScheme.onSurfaceVariant),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchText = "";
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Iconsax.search_normal_1_copy, size: 25, color: colorScheme.onSurfaceVariant),
                  onPressed: () => setState(() => _isSearching = true),
                  tooltip: "Search exercises",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                ),
        ],
      ),
    );
  }
}
