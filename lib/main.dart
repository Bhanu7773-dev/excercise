import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_firstapp/screens/goal_screen.dart';
import 'package:my_firstapp/screens/stopwatch_screen.dart';
import 'package:my_firstapp/widgets/music_tab.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:my_firstapp/screens/splash.dart';
import 'package:marquee/marquee.dart';

void main() => runApp(const MyApp());

enum SelectedPill { connection, status, music }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Tracker',
      theme: ThemeData.light()
          .copyWith(textTheme: GoogleFonts.montserratTextTheme()),
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

Future<Uint8List?> getAlbumArt(int songId) async {
  final OnAudioQuery query = OnAudioQuery();
  bool permission = await query.permissionsStatus();
  if (!permission) await query.permissionsRequest();
  return await query.queryArtwork(
    songId,
    ArtworkType.AUDIO,
  );
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
            child: const Text("Cancel"),
          ),
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
          const Padding(
            padding: EdgeInsets.only(left: 130),
            child: Icon(Iconsax.calendar, color: Colors.black, size: 30),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Iconsax.user, color: Colors.black),
          ),
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
          Text(
            "Fitness Tracking",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          Text(
            "with FIT-X ",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildQuote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Text(
        "“The only bad workout is the one that didn’t happen.”",
        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
      ),
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
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final name = exercises[index];
            final isGoal = goalExercises.contains(name);
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: isGoal
                    ? Text(
                        "Goal: ${exerciseGoals[name]} reps",
                        style: const TextStyle(color: Colors.white70),
                      )
                    : null,
                trailing: isGoal
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Iconsax.edit_2, color: Colors.white),
                            onPressed: () => editGoal(name),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.play, color: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalScreen(
                                  name: name,
                                  goal: exerciseGoals[name]!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Iconsax.timer_1, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StopwatchScreen(exercise: name),
                          ),
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
            child: Text(
              "Weekly Routine Coming Soon...",
              style: TextStyle(fontSize: 20),
            ),
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

    return Container(
      width: double.infinity,
      color: Colors.black,
      child: StreamBuilder<PlayerState>(
        stream: AudioService.audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final isPlaying = playerState?.playing ?? false;
          final processingState = playerState?.processingState;

          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return loadingWidget();
          }

          return musicControlWidget(isPlaying);
        },
      ),
    );
  }

  Widget loadingWidget() => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 15),
            Text("Loading...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );

  Widget musicControlWidget(bool isPlaying) {
    final song = AudioService.currentSong;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Song title
                    SizedBox(
                      height: 20,
                      child: Marquee(
                        text: song!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        blankSpace: 40,
                        velocity: 25,
                        fadingEdgeStartFraction: 0.1,
                        fadingEdgeEndFraction: 0.1,
                        startAfter: Duration(seconds: 1),
                        pauseAfterRound: Duration(seconds: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Iconsax.previous,
                              color: Colors.white70),
                          onPressed: () =>
                              AudioService.audioPlayer.seekToPrevious(),
                        ),
                        IconButton(
                          iconSize: 44,
                          icon: Icon(
                            isPlaying
                                ? Iconsax.pause_circle
                                : Iconsax.play_circle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            isPlaying
                                ? AudioService.audioPlayer.pause()
                                : AudioService.audioPlayer.play();
                          },
                        ),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Iconsax.next, color: Colors.white70),
                          onPressed: () =>
                              AudioService.audioPlayer.seekToNext(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Positioned album art (overlapping)
        Positioned(
          top: -10,
          left: 16,
          child: FutureBuilder<Uint8List?>(
            future: getAlbumArt(song.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[800]!, width: 6),
                    color: Colors.grey[700],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(snapshot.data!),
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[800]!, width: 6),
                    color: Colors.grey[700],
                  ),
                  child: const Icon(Iconsax.musicnote, color: Colors.white),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTopBar(),
          buildHeading(),
          buildQuote(),
          buildPills(),
          buildContentArea(),
          buildMusicBar(),
        ],
      ),
    );
  }
}
