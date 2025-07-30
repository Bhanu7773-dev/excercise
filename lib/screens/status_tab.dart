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
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: FutureBuilder<List<Exercise>>(
            future: _filteredExercisesFuture,
            builder: (context, snapshot) {
              final exercises = snapshot.data ?? [];
              final repExercises =
                  exercises.where((e) => !e.isTimeBased).toList();
              final timeExercises =
                  exercises.where((e) => e.isTimeBased).toList();

              final repNames = repExercises.map((e) => e.name).toSet().toList();
              if (selectedRepExercise == null && repNames.isNotEmpty) {
                selectedRepExercise = repNames.first;
              }

              final timeNames =
                  timeExercises.map((e) => e.name).toSet().toList();
              if (selectedTimeExercise == null && timeNames.isNotEmpty) {
                selectedTimeExercise = timeNames.first;
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
              List<double> repLeftTitles = [
                for (double y = 0; y <= repYMax; y += 50) y
              ];

              double maxMin = timeBuckets.isNotEmpty
                  ? timeBuckets.reduce((a, b) => a > b ? a : b)
                  : 0;
              double lineYMax = ((maxMin / 5).ceil() * 5).toDouble();
              if (lineYMax < 5) lineYMax = 5;
              List<double> timeLeftTitles = [
                for (double y = 0; y <= lineYMax; y += 5) y
              ];

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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.white),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
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
                            side: BorderSide(color: Colors.white10, width: 1),
                          ),
                          color: Colors.grey[900],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text("Rep Exercise: ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.black,
                                      value: selectedRepExercise,
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.white),
                                      items: repNames
                                          .map((name) => DropdownMenuItem(
                                                value: name,
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(
                                            () => selectedRepExercise = val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 120,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      minY: 0,
                                      maxY: repYMax,
                                      barTouchData:
                                          BarTouchData(enabled: false),
                                      gridData: FlGridData(
                                          show: true, horizontalInterval: 50),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 50,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              if (repLeftTitles
                                                  .contains(value)) {
                                                return Text(
                                                  value.round().toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (v, meta) {
                                              int idx = v.toInt();
                                              if (idx < 0 || idx > 6)
                                                return const SizedBox.shrink();
                                              return Text(
                                                weekDays[idx],
                                                style: const TextStyle(
                                                    color: Colors.white,
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
                                              color: Colors.greenAccent,
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
                                const Text(
                                  "Swipe left for timed exercise graph →",
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Colors.white10, width: 1),
                          ),
                          color: Colors.grey[900],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text("Timed Exercise: ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.black,
                                      value: selectedTimeExercise,
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.white),
                                      items: timeNames
                                          .map((name) => DropdownMenuItem(
                                                value: name,
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(
                                            () => selectedTimeExercise = val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 120,
                                  child: LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: 7,
                                      minY: 0,
                                      maxY: lineYMax,
                                      gridData: FlGridData(
                                          show: true, horizontalInterval: 5),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 5,
                                            reservedSize: 40,
                                            getTitlesWidget: (v, meta) {
                                              return Text(
                                                "${v.round()} min",
                                                style: const TextStyle(
                                                    color: Colors.white,
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
                                                  idx >= buckets.length)
                                                return const SizedBox.shrink();
                                              return Text(
                                                buckets[idx],
                                                style: const TextStyle(
                                                    color: Colors.white,
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
                                          color: Colors.greenAccent,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "← Swipe right for rep exercise graph",
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
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
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "Reset Progress",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
                            backgroundColor: Colors.grey[900],
                            title: const Text("Reset All Progress?"),
                            content: const Text(
                              "This will clear all your progress for today. This cannot be undone. Are you sure?",
                              style: TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
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
    final sortedExercises = List<Exercise>.from(exercises)
      ..sort((a, b) => b.lastCompleted.compareTo(a.lastCompleted));
    return List.generate(
      sortedExercises.length,
      (index) => _exerciseListTile(sortedExercises[index]),
    );
  }

  Widget _exerciseListTile(Exercise exercise) {
    final isTimeBased = exercise.isTimeBased;
    final totalValue = isTimeBased
        ? exercise.totalDuration.inSeconds.toDouble()
        : exercise.totalReps.toDouble();
    final progressPercent = (totalValue / 300).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isTimeBased
                ? '${exercise.totalDuration.inMinutes} min ${exercise.totalDuration.inSeconds % 60} sec completed'
                : '${exercise.totalReps} reps completed',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last: ${exercise.lastCompleted.toLocal().toString().split('.')[0]}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
