import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/exercise_data.dart';

class StatusTab extends StatefulWidget {
  final List<Exercise> completedExercises;
  final VoidCallback onReset;
  final Future<List<Exercise>> Function(DateTime date) getExercisesByDate;

  const StatusTab({
    super.key,
    required this.completedExercises,
    required this.onReset,
    required this.getExercisesByDate,
  });

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  DateTime selectedDate = DateTime.now();
  late Future<List<Exercise>> _filteredExercisesFuture;
  String? selectedRepExercise;
  String? selectedTimeExercise;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredExercisesFuture = widget.getExercisesByDate(selectedDate);
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _filteredExercisesFuture = widget.getExercisesByDate(selectedDate);
    });
  }

  List<String> getTimeBuckets() {
    final List<String> buckets = [];
    for (int h = 0; h < 24; h += 3) {
      final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final period = h < 12 ? "am" : "pm";
      buckets.add("$hour$period");
    }
    return buckets;
  }

  int getTimeBucketIndex(DateTime dt) => dt.hour ~/ 3;

  List<String> getWeekdays() =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        color: colorScheme.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: FutureBuilder<List<Exercise>>(
            future: _filteredExercisesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final exercises = snapshot.data ?? [];
              final repExercises =
                  exercises.where((e) => !e.isTimeBased).toList();
              final timeExercises =
                  exercises.where((e) => e.isTimeBased).toList();

              final repNames = repExercises.map((e) => e.name).toSet().toList();
              if (selectedRepExercise == null && repNames.isNotEmpty) {
                selectedRepExercise = repNames.first;
              } else if (repNames.isEmpty) {
                selectedRepExercise = null;
              }

              final timeNames =
                  timeExercises.map((e) => e.name).toSet().toList();
              if (selectedTimeExercise == null && timeNames.isNotEmpty) {
                selectedTimeExercise = timeNames.first;
              } else if (timeNames.isEmpty) {
                selectedTimeExercise = null;
              }

              final weekDays = getWeekdays();
              final weekStart = getStartOfWeek(selectedDate);
              List<int> repTotals = List.generate(7, (i) {
                final day = weekStart.add(Duration(days: i));
                final dayEx = repExercises.where(
                  (e) =>
                      e.name == selectedRepExercise &&
                      e.lastCompleted.year == day.year &&
                      e.lastCompleted.month == day.month &&
                      e.lastCompleted.day == day.day,
                );
                return dayEx.fold<int>(0, (sum, e) => sum + e.totalReps);
              });

              final buckets = getTimeBuckets();
              List<double> timeBuckets = List.filled(buckets.length, 0);
              if (selectedTimeExercise != null) {
                for (var e in timeExercises
                    .where((e) => e.name == selectedTimeExercise)) {
                  final bIdx = getTimeBucketIndex(e.lastCompleted);
                  timeBuckets[bIdx] += e.totalDuration.inSeconds / 60.0;
                }
              }

              int maxRep = repTotals.isNotEmpty
                  ? repTotals.reduce((a, b) => a > b ? a : b)
                  : 0;
              double repYMax = ((maxRep / 50).ceil() * 50).toDouble();
              if (repYMax < 50) repYMax = 50;

              double maxMin = timeBuckets.isNotEmpty
                  ? timeBuckets.reduce((a, b) => a > b ? a : b)
                  : 0;
              double lineYMax = ((maxMin / 5).ceil() * 5).toDouble();
              if (lineYMax < 5) lineYMax = 5;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Your Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month,
                            color: colorScheme.onBackground),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: colorScheme.copyWith(
                                    primary: colorScheme.primary,
                                    onPrimary: colorScheme.onPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            _onDateChanged(picked);
                          }
                        },
                        tooltip: "Filter by date",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PageView(
                      controller: PageController(initialPage: pageIndex),
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: colorScheme.outline.withOpacity(0.2),
                                width: 1),
                          ),
                          color: colorScheme.surfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text("Rep Exercise: ",
                                        style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold)),
                                    if (repNames.isNotEmpty)
                                      DropdownButton<String>(
                                        dropdownColor: colorScheme.surface,
                                        value: selectedRepExercise,
                                        icon: Icon(Icons.arrow_drop_down,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        items: repNames
                                            .map((name) => DropdownMenuItem(
                                                  value: name,
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                        color: colorScheme
                                                            .onSurface),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          setState(
                                              () => selectedRepExercise = val);
                                        },
                                      )
                                    else
                                      Text(
                                        "No Data",
                                        style: TextStyle(
                                            color: colorScheme.outline),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      minY: 0,
                                      maxY: repYMax,
                                      barTouchData:
                                          BarTouchData(enabled: false),
                                      gridData: FlGridData(
                                          show: true,
                                          horizontalInterval: 50,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                                color: colorScheme.outline
                                                    .withOpacity(0.2),
                                                strokeWidth: 1);
                                          }),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 50,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.round().toString(),
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 11),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (v, meta) {
                                              int idx = v.toInt();
                                              if (idx < 0 || idx > 6) {
                                                return const SizedBox.shrink();
                                              }
                                              return Text(
                                                weekDays[idx],
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 11),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(
                                        7,
                                        (i) => BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: repTotals[i].toDouble(),
                                              width: 18,
                                              color: colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Swipe left for timed exercise graph →",
                                  style: TextStyle(
                                      color: colorScheme.outline, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: colorScheme.outline.withOpacity(0.2),
                                width: 1),
                          ),
                          color: colorScheme.surfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text("Timed Exercise: ",
                                        style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold)),
                                    if (timeNames.isNotEmpty)
                                      DropdownButton<String>(
                                        dropdownColor: colorScheme.surface,
                                        value: selectedTimeExercise,
                                        icon: Icon(Icons.arrow_drop_down,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        items: timeNames
                                            .map((name) => DropdownMenuItem(
                                                  value: name,
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                        color: colorScheme
                                                            .onSurface),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          setState(
                                              () => selectedTimeExercise = val);
                                        },
                                      )
                                    else
                                      Text(
                                        "No Data",
                                        style: TextStyle(
                                            color: colorScheme.outline),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: 7,
                                      minY: 0,
                                      maxY: lineYMax,
                                      gridData: FlGridData(
                                          show: true,
                                          horizontalInterval: 5,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                                color: colorScheme.outline
                                                    .withOpacity(0.2),
                                                strokeWidth: 1);
                                          }),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 5,
                                            reservedSize: 40,
                                            getTitlesWidget: (v, meta) {
                                              return Text(
                                                "${v.round()} min",
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 10),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (v, meta) {
                                              int idx = v.toInt();
                                              if (idx < 0 ||
                                                  idx >= buckets.length) {
                                                return const SizedBox.shrink();
                                              }
                                              return Text(
                                                buckets[idx],
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 10),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(
                                              buckets.length,
                                              (i) => FlSpot(i.toDouble(),
                                                  timeBuckets[i])),
                                          isCurved: false,
                                          color: colorScheme.primary,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "← Swipe right for rep exercise graph",
                                  style: TextStyle(
                                      color: colorScheme.outline, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._exerciseListTiles(exercises),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.refresh, color: colorScheme.onError),
                      label: Text(
                        "Reset Progress",
                        style: TextStyle(color: colorScheme.onError),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: colorScheme.surfaceVariant,
                            title: Text("Reset All Progress?",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            content: Text(
                              "This will clear all your progress for today. This cannot be undone. Are you sure?",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: colorScheme.onSurfaceVariant)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                ),
                                child: const Text("Reset"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          widget.onReset();
                          _onDateChanged(selectedDate);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _exerciseListTiles(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "No exercises completed on this day.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        )
      ];
    }
    final sortedExercises = List<Exercise>.from(exercises)
      ..sort((a, b) => b.lastCompleted.compareTo(a.lastCompleted));
    return List.generate(
      sortedExercises.length,
      (index) => _exerciseListTile(sortedExercises[index]),
    );
  }

  Widget _exerciseListTile(Exercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTimeBased = exercise.isTimeBased;
    final totalValue = isTimeBased
        ? exercise.totalDuration.inSeconds.toDouble()
        : exercise.totalReps.toDouble();
    final progressPercent = (totalValue / 300).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isTimeBased
                ? '${exercise.totalDuration.inMinutes} min ${exercise.totalDuration.inSeconds % 60} sec completed'
                : '${exercise.totalReps} reps completed',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last: ${exercise.lastCompleted.toLocal().toString().split('.')[0]}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
