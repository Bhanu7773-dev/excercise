import 'package:flutter/material.dart';
import 'dart:async';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // back button color
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
        ],
      ),
    );
  }
}
