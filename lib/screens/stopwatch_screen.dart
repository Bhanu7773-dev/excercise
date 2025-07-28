import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../model/exercise_data.dart';
import '../model/exercise_status_provider.dart';

class StopwatchScreen extends StatefulWidget {
  final String exercise;
  const StopwatchScreen({super.key, required this.exercise});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = "00:00";

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          final minutes =
              _stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
          final seconds =
              (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          _elapsedTime = "$minutes:$seconds";
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _start() => setState(() => _stopwatch.start());
  void _pause() => setState(() => _stopwatch.stop());
  void _reset() {
    setState(() {
      _stopwatch.reset();
      _elapsedTime = "00:00";
    });
  }

  void _complete() {
    if (_stopwatch.elapsed.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please record some time before completing!')),
      );
      return;
    }

    final completedExercise = Exercise(
      name: widget.exercise,
      isTimeBased: true,
      totalReps: 0,
      totalDuration: _stopwatch.elapsed,
      lastCompleted: DateTime.now(),
    );

    Provider.of<ExerciseStatusProvider>(context, listen: false)
        .addCompletedExercise(completedExercise);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time-based exercise recorded!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.exercise,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_elapsedTime,
              style: const TextStyle(color: Colors.white, fontSize: 48)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child:
                    const Text('Start', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _pause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child:
                    const Text('Pause', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child:
                    const Text('Reset', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _complete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
