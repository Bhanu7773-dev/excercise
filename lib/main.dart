import 'package:flutter/material.dart';
import 'package:my_firstapp/screens/goal_screen.dart';
import 'package:my_firstapp/screens/stopwatch_screen.dart';
import 'package:my_firstapp/widgets/music_tab.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:my_firstapp/screens/splash.dart';

void main() => runApp(const MyApp());

enum SelectedPill { connection, status, music }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Tracker',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AudioService {
  static final AudioPlayer audioPlayer = AudioPlayer();
  static SongModel? currentSong;
  static ConcatenatingAudioSource? playlist;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SelectedPill selectedPill = SelectedPill.connection;

  Map<String, int> exerciseGoals = {
    'Push Ups': 10,
    'Sit Ups': 10,
    'Squats': 10,
  };

  final List<String> goalExercises = ['Push Ups', 'Sit Ups', 'Squats'];
  final List<String> stopwatchExercises = [
    'Plank',
    'Jumping Jacks',
    'Running',
    'Lunges',
    'Mountain Climbers',
    'Burpees',
  ];

  void editGoal(String name) async {
    TextEditingController controller =
        TextEditingController(text: exerciseGoals[name].toString());

    final updated = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New goal count"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              Navigator.pop(context, newGoal);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (updated != null) {
      setState(() {
        exerciseGoals[name] = updated;
      });
    }
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/image/logo.png',
            width: 130,
            height: 130,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 130),
            child:
                const Icon(Icons.calendar_today, color: Colors.black, size: 30),
          ),
          //avatar
          CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildHeading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Fitness Tracking",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          Text("with FIT-X ",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildQuote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Text("“The only bad workout is the one that didn’t happen.”",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
    );
  }

  Widget buildPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          buildPill("WORKOUT", SelectedPill.connection),
          const SizedBox(width: 10),
          buildPill("STATUS", SelectedPill.status),
          const SizedBox(width: 10),
          buildPill("MUSIC", SelectedPill.music),
        ],
      ),
    );
  }

  Widget buildPill(String label, SelectedPill pill) {
    bool isSelected = selectedPill == pill;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => selectedPill = pill),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const StadiumBorder(),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildExerciseList() {
    final exercises = [...goalExercises, ...stopwatchExercises];
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final name = exercises[index];
            final isGoal = goalExercises.contains(name);
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                subtitle: isGoal
                    ? Text("Goal: ${exerciseGoals[name]} reps",
                        style: const TextStyle(color: Colors.white70))
                    : null,
                trailing: isGoal
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => editGoal(name)),
                          IconButton(
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => GoalScreen(
                                      name: name, goal: exerciseGoals[name]!)),
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Icons.timer, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => StopwatchScreen(exercise: name)),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildContentArea() {
    switch (selectedPill) {
      case SelectedPill.connection:
        return buildExerciseList();
      case SelectedPill.status:
        return const Expanded(
          child: Center(
            child: Text("Weekly Routine Coming Soon...",
                style: TextStyle(fontSize: 20)),
          ),
        );
      case SelectedPill.music:
        return MusicTab(
          onSongPlayed: () => setState(() {}),
        );
    }
  }

  Widget buildMusicBar() {
    if (AudioService.currentSong == null) return const SizedBox.shrink();

    return StreamBuilder<PlayerState>(
      stream: AudioService.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final processingState = playerState?.processingState;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 15),
                Text("Loading...", style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.music_note, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AudioService.currentSong!.title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () => AudioService.audioPlayer.seekToPrevious(),
              ),
              IconButton(
                iconSize: 32,
                icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white),
                onPressed: () {
                  isPlaying
                      ? AudioService.audioPlayer.pause()
                      : AudioService.audioPlayer.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () => AudioService.audioPlayer.seekToNext(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopBar(),
            buildHeading(),
            buildQuote(),
            const SizedBox(height: 10),
            buildPills(),
            buildContentArea(),
            buildMusicBar(),
          ],
        ),
      ),
    );
  }
}
