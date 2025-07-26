import 'package:flutter/material.dart';
import 'dart:async';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(MyApp());

enum SelectedPill { connection, status, music }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Tracker',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AudioService {
  static final AudioPlayer audioPlayer = AudioPlayer();
  static SongModel? currentSong;
  static bool isPlaying = false;
}

class HomePage extends StatefulWidget {
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

  void incrementGoal(String name) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Increase Goal?"),
        content: Text("Do you want to increase your $name goal by 5?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        exerciseGoals[name] = exerciseGoals[name]! + 5;
      });
    }
  }

  void editGoal(String name) async {
    TextEditingController controller =
        TextEditingController(text: exerciseGoals[name].toString());

    final updated = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "New goal count"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              Navigator.pop(context, newGoal);
            },
            child: Text("Save"),
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
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.arrow_back, color: Colors.white)),
          Text("FIT-X",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Icon(Icons.calendar_today),
          CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          SizedBox(width: 10),
          buildPill("STATUS", SelectedPill.status),
          SizedBox(width: 10),
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
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: StadiumBorder(),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildExerciseList() {
    final exercises = [...goalExercises, ...stopwatchExercises];
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView.builder(
          padding: EdgeInsets.all(20),
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
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Text(name,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                subtitle: isGoal
                    ? Text("Goal: ${exerciseGoals[name]} reps",
                        style: TextStyle(color: Colors.white70))
                    : null,
                trailing: isGoal
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => editGoal(name)),
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: Colors.white),
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
                        icon: Icon(Icons.play_arrow, color: Colors.white),
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
        return Expanded(
          child: Center(
            child: Text("Weekly Routine Coming Soon...",
                style: TextStyle(fontSize: 20)),
          ),
        );
      case SelectedPill.music:
        return MusicTab();
    }
  }

  Widget buildMusicBar() {
    final song = AudioService.currentSong;
    if (song == null) return SizedBox();
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.music_note, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              song.title,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.skip_previous, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(AudioService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white),
            onPressed: () async {
              if (AudioService.isPlaying) {
                await AudioService.audioPlayer.pause();
              } else {
                await AudioService.audioPlayer.play();
              }
              setState(() {
                AudioService.isPlaying = !AudioService.isPlaying;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.skip_next, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopBar(),
            buildHeading(),
            buildQuote(),
            SizedBox(height: 10),
            buildPills(),
            buildContentArea(),
            buildMusicBar(),
          ],
        ),
      ),
    );
  }
}

class MusicTab extends StatefulWidget {
  @override
  _MusicTabState createState() => _MusicTabState();
}

class _MusicTabState extends State<MusicTab> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    AudioService.audioPlayer.playerStateStream.listen((state) {
      setState(() {
        AudioService.isPlaying = state.playing;
      });
    });
  }

  Future<void> _fetchSongs() async {
    final songs = await _audioQuery.querySongs();
    setState(() {
      _songs = songs;
    });
  }

  void _playSong(SongModel song) async {
    if (song.uri == null) return;
    if (AudioService.currentSong?.id == song.id && AudioService.isPlaying) {
      await AudioService.audioPlayer.pause();
    } else {
      await AudioService.audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      await AudioService.audioPlayer.play();
      setState(() {
        AudioService.currentSong = song;
        AudioService.isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView.builder(
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            final song = _songs[index];
            final isCurrent = AudioService.currentSong?.id == song.id;

            return ListTile(
              title: Text(song.title,
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline)),
              subtitle: Text(song.artist ?? 'Unknown',
                  style: TextStyle(color: Colors.white70)),
              trailing: Icon(
                  isCurrent && AudioService.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white),
              onTap: () => _playSong(song),
            );
          },
        ),
      ),
    );
  }
}

// Dummy Screens (replace with real ones if needed)
class GoalScreen extends StatelessWidget {
  final String name;
  final int goal;
  GoalScreen({required this.name, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('$name Goal: $goal reps',
            style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}

class StopwatchScreen extends StatelessWidget {
  final String exercise;
  StopwatchScreen({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Stopwatch for $exercise',
            style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}
