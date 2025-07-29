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
import 'package:fl_chart/fl_chart.dart';
import '../model/exercise_data.dart';
import 'package:provider/provider.dart';
import '../model/exercise_status_provider.dart';
// Avatar imports
import '../model/avatar_provider.dart';
import '../screens/edit_avatar_page.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExerciseStatusProvider()),
          ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ],
        child: const MyApp(),
      ),
    );

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

  // --- ICON MAPPING FOR EXERCISES ---
  IconData getExerciseIcon(String name) {
    switch (name.toLowerCase()) {
      case 'push ups':
        return Icons.fitness_center;
      case 'sit ups':
        return Icons.self_improvement;
      case 'squats':
        return Icons.accessibility_new;
      case 'plank':
        return Icons.horizontal_rule;
      case 'jumping jacks':
        return Icons.sports_martial_arts; // Or: Icons.directions_run
      case 'running':
        return Icons.directions_run;
      case 'lunges':
        return Icons.directions_walk;
      case 'mountain climbers':
        return Icons.terrain;
      case 'burpees':
        return Icons.sports_kabaddi;
      default:
        return Icons.sports_gymnastics;
    }
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
    // Ensure user name is loaded on HomePage startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AvatarProvider>(context, listen: false).loadUserName();
    });
  }

  // ---- MODIFIED TOP BAR: Avatar icon logic added here ----
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
                    Icons.calendar_today_sharp,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // <<<< Avatar Consumer button replaces person icon
              Consumer<AvatarProvider>(
                builder: (context, avatarProvider, _) {
                  final avatarFile = avatarProvider.avatarFile;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditAvatarPage()),
                        );
                      },
                      icon: avatarFile != null
                          ? CircleAvatar(
                              radius: 18,
                              backgroundImage: FileImage(avatarFile),
                              backgroundColor: Colors.transparent,
                            )
                          : const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.person_outline,
                                  color: Colors.white),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ---- END TOP BAR ----

  Widget buildHeading() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, _) {
        final userName = avatarProvider.userName;
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
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userName != null && userName.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "$userName, remember:",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Text(
                            "The only bad workout is the one that didn't happen.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  // CHANGE: Tilted dumbbell icon for "Your Library" (using Icons.fitness_center with Transform)
  Widget buildMusicLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: 0.0, // ~-20 degrees
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
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
                  Icons.fitness_center,
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

  // UPDATED: Show correct icon for each exercise
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
                            getExerciseIcon(name),
                            color: Colors.black,
                            size: 22,
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
            child: Consumer<ExerciseStatusProvider>(
              builder: (context, provider, child) => StatusTab(
                completedExercises: provider.completedExercises,
                onReset: provider.clearAll,
                getExercisesByDate: provider.getExercisesByDate,
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

// StatusTab remains unchanged; it will now always get up-to-date data via the provider.
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

// ... (rest of StatusTab code unchanged) ...
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
    // Monday as the start of the week
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

              // Rep-based: dropdown options
              final repNames = repExercises.map((e) => e.name).toSet().toList();
              if (selectedRepExercise == null && repNames.isNotEmpty) {
                selectedRepExercise = repNames.first;
              }

              // Time-based: dropdown options
              final timeNames =
                  timeExercises.map((e) => e.name).toSet().toList();
              if (selectedTimeExercise == null && timeNames.isNotEmpty) {
                selectedTimeExercise = timeNames.first;
              }

              // For rep-based: For selected exercise, sum reps for each day of this week
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

              // For time-based: selected exercise, create 8 buckets for the day (3-hour intervals)
              final buckets = getTimeBuckets();
              List<double> timeBuckets = List.filled(buckets.length, 0);
              if (selectedTimeExercise != null) {
                for (var e in timeExercises
                    .where((e) => e.name == selectedTimeExercise)) {
                  final bIdx = getTimeBucketIndex(e.lastCompleted);
                  timeBuckets[bIdx] += e.totalDuration.inSeconds / 60.0;
                }
              }

              // --- Auto Y axis for bar graph (reps) ---
              int maxRep = repTotals.isNotEmpty
                  ? repTotals.reduce((a, b) => a > b ? a : b)
                  : 0;
              double repYMax = ((maxRep / 50).ceil() * 50).toDouble();
              if (repYMax < 50) repYMax = 50;
              List<double> repLeftTitles = [
                for (double y = 0; y <= repYMax; y += 50) y
              ];

              // --- Auto Y axis for line graph (time/minutes) ---
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
                  // Title and filter
                  Row(
                    children: [
                      Expanded(
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
                  // Swipable Graphs
                  SizedBox(
                    height: 220,
                    child: PageView(
                      controller: PageController(initialPage: pageIndex),
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: [
                        // --- Bar Chart Card (Reps, week) ---
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
                        // --- Line Chart Card (Timed) ---
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
                  // --- Reset button at bottom ---
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
                          _onDateChanged(selectedDate); // refresh view
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
