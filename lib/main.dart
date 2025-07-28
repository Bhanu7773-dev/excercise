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
import 'package:strange_icons/strange_icons.dart';

void main() => runApp(const MyApp());

enum SelectedPill { connection, status, music }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          background: const Color(0xFF0D0D0D),
          surface: const Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          background: const Color(0xFF0D0D0D),
          surface: const Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.dark,
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  SelectedPill selectedPill = SelectedPill.connection;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void editGoal(String name) async {
    TextEditingController controller =
        TextEditingController(text: exerciseGoals[name].toString());

    final updated = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Edit Goal",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: "New goal count",
            labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              Navigator.pop(context, newGoal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
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
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Iconsax.flash,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.calendar,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.user,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fitness Tracking",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1.1,
            ),
          ),
          Text(
            "with FIT-X",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.quote_up,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "The only bad workout is the one that didn't happen.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPills() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          buildPill("WORKOUT", SelectedPill.connection, Iconsax.flash),
          buildPill("STATUS", SelectedPill.status, Iconsax.chart_2),
          buildPill("MUSIC", SelectedPill.music, Iconsax.musicnote),
        ],
      ),
    );
  }

  Widget buildPill(String label, SelectedPill pill, IconData icon) {
    bool isSelected = selectedPill == pill;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: () {
            setState(() => selectedPill = pill);
            _animationController.reset();
            _animationController.forward();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMusicLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.musicnote,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  FutureBuilder<List<SongModel>>(
                    future: OnAudioQuery().querySongs(),
                    builder: (context, snapshot) {
                      final songCount = snapshot.data?.length ?? 0;
                      return Text(
                        "$songCount songs",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.flash,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workout Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${goalExercises.length + stopwatchExercises.length} exercises",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExerciseList() {
    final exercises = [...goalExercises, ...stopwatchExercises];
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              buildWorkoutLibrary(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final name = exercises[index];
                    final isGoal = goalExercises.contains(name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isGoal
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isGoal ? Iconsax.add : Iconsax.timer_1_copy,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGoal
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2)
                                : const Color(0xFFFF6B35).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isGoal
                                ? "Goal: ${exerciseGoals[name]} reps"
                                : "Time-based exercise",
                            style: TextStyle(
                              color: isGoal
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFFF6B35),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        trailing: isGoal
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3A3A3A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Iconsax.edit_2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        size: 18,
                                      ),
                                      onPressed: () => editGoal(name),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Iconsax.play, size: 16),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GoalScreen(
                                            name: name,
                                            goal: exerciseGoals[name]!,
                                          ),
                                        ),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(SandowSolidIcons.play,
                                      size: 20),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StopwatchScreen(exercise: name),
                                    ),
                                  ),
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Iconsax.chart_2,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Weekly Routine",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Coming Soon...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case SelectedPill.music:
        return Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  buildMusicLibrary(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: MusicTab(
                      onSongPlayed: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget buildMusicBar() {
    if (AudioService.currentSong == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
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
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "Loading...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget musicControlWidget(bool isPlaying) {
    final song = AudioService.currentSong;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          FutureBuilder<Uint8List?>(
            future: getAlbumArt(song!.id),
            builder: (context, snapshot) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                  image: snapshot.hasData && snapshot.data != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(snapshot.data!),
                        )
                      : null,
                ),
                child: snapshot.hasData && snapshot.data != null
                    ? null
                    : Icon(
                        Iconsax.musicnote,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Marquee(
                    text: song.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    blankSpace: 40,
                    velocity: 25,
                    fadingEdgeStartFraction: 0.1,
                    fadingEdgeEndFraction: 0.1,
                    startAfter: const Duration(seconds: 1),
                    pauseAfterRound: const Duration(seconds: 1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist ?? "Unknown Artist",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 20,
                icon: Icon(
                  Iconsax.previous,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => AudioService.audioPlayer.seekToPrevious(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    isPlaying ? Iconsax.pause : Iconsax.play,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    isPlaying
                        ? AudioService.audioPlayer.pause()
                        : AudioService.audioPlayer.play();
                  },
                ),
              ),
              IconButton(
                iconSize: 20,
                icon: Icon(
                  Iconsax.next,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => AudioService.audioPlayer.seekToNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopBar(),
            buildHeading(),
            buildPills(),
            buildContentArea(),
            buildMusicBar(),
          ],
        ),
      ),
    );
  }
}
