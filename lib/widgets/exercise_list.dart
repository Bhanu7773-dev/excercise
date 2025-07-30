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
                  color: const Color(0xFF1B2222),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.06),
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
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.13)
                          : const Color(0xFFFF6B35).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.getExerciseIcon(name),
                      color: isGoal
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFFF6B35),
                      size: 26,
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isGoal
                        ? "Goal: ${widget.exerciseGoals[name]} reps"
                        : "Time-based exercise",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                color: const Color(0xFF262D2D),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Iconsax.edit_2,
                                  color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.onPrimary,
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
                            color: const Color(0xFFFF6B35).withOpacity(0.18),
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
                            color: const Color(0xFFFF6B35),
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
    return Padding(
      // ALIGN HORIZONTALLY with list: Use left=18 to match ListTile's horizontal:18
      padding: const EdgeInsets.only(
          left: 18, right: 12), // left=18, right matches list padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.onPrimary,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${widget.goalExercises.length + widget.stopwatchExercises.length} exercises",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Search exercises...",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 18),
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
                  icon: const Icon(Iconsax.search_normal_1_copy, size: 25),
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
