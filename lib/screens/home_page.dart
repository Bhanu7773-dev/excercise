import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:intl/intl.dart';
import 'package:my_firstapp/model/avatar_provider.dart';
import 'package:my_firstapp/model/exercise_status_provider.dart';
import 'package:my_firstapp/widgets/music_tab.dart';
import 'package:my_firstapp/widgets/music_bar.dart';
import 'package:my_firstapp/widgets/exercise_list.dart';
import 'package:my_firstapp/utils/audio_utils.dart';
import 'edit_avatar_page.dart';
import 'status_tab.dart';

enum SelectedPill { connection, status, music }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  SelectedPill selectedPill = SelectedPill.connection;
  late AnimationController _pillController;
  late Animation<double> _pillAnim;

  Map<String, int> exerciseGoals = {
    'Push Ups': 10,
    'Sit Ups': 10,
    'Squats': 10,
    'Lunges': 10,
    'Tricep Dips': 10,
    'Mountain Climbers': 20,
    'Burpees': 10,
    'Jumping Jacks': 20,
    'High Knees': 20,
    'Crunches': 15,
    'Leg Raises': 10,
    'Russian Twists': 20,
    'Inchworms': 10,
    'Glute Bridges': 15,
    'Bicycle Crunches': 20,
    'Supermans': 10,
    'Step-Ups (on stairs)': 20,
    'Wall Push Ups': 10,
    'Reverse Lunges': 10,
    'Heel Touches': 20,
    'Donkey Kicks': 15,
    'Standing Calf Raises': 15,
    'Side Lunges': 10,
    'Squat Jumps': 10,
    'Plank Up-Downs': 10,
    'Clapping Push Ups': 8,
    'Flutter Kicks': 20,
    'Hip Thrusts': 15,
    'Spiderman Push Ups': 8,
    'Diamond Push Ups': 8,
  };

  final List<String> goalExercises = [
    'Push Ups',
    'Sit Ups',
    'Squats',
    'Lunges',
    'Tricep Dips',
    'Mountain Climbers',
    'Burpees',
    'Jumping Jacks',
    'High Knees',
    'Crunches',
    'Leg Raises',
    'Russian Twists',
    'Inchworms',
    'Glute Bridges',
    'Bicycle Crunches',
    'Supermans',
    'Step-Ups (on stairs)',
    'Wall Push Ups',
    'Reverse Lunges',
    'Heel Touches',
    'Donkey Kicks',
    'Standing Calf Raises',
    'Side Lunges',
    'Squat Jumps',
    'Plank Up-Downs',
    'Clapping Push Ups',
    'Flutter Kicks',
    'Hip Thrusts',
    'Spiderman Push Ups',
    'Diamond Push Ups',
  ];

  final List<String> stopwatchExercises = [
    'Plank',
    'Wall Sit',
    'High Knees (Timed)',
    'Butt Kicks',
    'Jog in Place',
    'Bear Crawl',
    'Side Plank (Left)',
    'Side Plank (Right)',
    'Reverse Plank',
    'Superman Hold',
    'Mountain Climbers (Timed)',
    'Jump Rope (Imaginary)',
    'Shadow Boxing',
    'Arm Circles',
    'Tuck Jumps',
    'Star Jumps',
    'Knee Plank',
    'Isometric Squat',
    'Dead Bug Hold',
    'Hollow Body Hold',
    'Bird Dog Hold',
    'L-Sit Hold (on floor or chairs)',
    'Hip Bridge Hold',
    'V-Sit Hold',
    'Single Leg Balance (Left)',
    'Single Leg Balance (Right)',
    'Chair Pose (Yoga)',
    'Side Lying Leg Raise Hold (Left)',
    'Side Lying Leg Raise Hold (Right)',
    'Boat Pose',
    'Crab Hold',
  ];

  bool _isMusicSearching = false;
  String _musicSearchText = '';

  final List<_PillMeta> pills = [
    _PillMeta("WORKOUT", SelectedPill.connection, Iconsax.flash),
    _PillMeta("STATUS", SelectedPill.status, Iconsax.chart_2),
    _PillMeta("MUSIC", SelectedPill.music, Iconsax.musicnote),
  ];

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _pillAnim =
        CurvedAnimation(parent: _pillController, curve: Curves.easeOutCubic);
    _pillController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AvatarProvider>(context, listen: false).loadUserName();
    });
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _onPillTap(int newIndex) {
    if (newIndex == pills.indexWhere((p) => p.pill == selectedPill)) return;
    setState(() {
      selectedPill = pills[newIndex].pill;
    });
  }

  /// --- FIXED BUILD PILLS ---
  Widget buildPills() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerPadding = 4;
        double totalWidth = constraints.maxWidth - containerPadding * 2;
        final pillCount = pills.length;
        final pillWidth = totalWidth / pillCount;
        final selectedIndex = pills.indexWhere((p) => p.pill == selectedPill);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Animated selector background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * pillWidth,
                  top: 0,
                  bottom: 0,
                  width: pillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Row of pill buttons
                Row(
                  children: pills.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pillMeta = entry.value;
                    final isSelected = selectedPill == pillMeta.pill;
                    return SizedBox(
                      width: pillWidth,
                      child: GestureDetector(
                        onTap: () => _onPillTap(idx),
                        child: Container(
                          height: 44,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  pillMeta.icon,
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  child: Text(
                                    pillMeta.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData getExerciseIcon(String name) {
    switch (name.toLowerCase()) {
      case 'push ups':
      case 'wall push ups':
      case 'diamond push ups':
      case 'clapping push ups':
      case 'spiderman push ups':
        return Icons.fitness_center;
      case 'sit ups':
      case 'crunches':
      case 'bicycle crunches':
      case 'leg raises':
      case 'flutter kicks':
      case 'heel touches':
      case 'russian twists':
      case 'v-sit hold':
      case 'dead bug hold':
      case 'hollow body hold':
      case 'boat pose':
        return Icons.self_improvement;
      case 'squats':
      case 'isometric squat':
      case 'squat jumps':
      case 'side lunges':
      case 'reverse lunges':
      case 'lunges':
      case 'step-ups (on stairs)':
      case 'chair pose (yoga)':
        return Icons.accessibility_new;
      case 'plank':
      case 'side plank (left)':
      case 'side plank (right)':
      case 'reverse plank':
      case 'plank up-downs':
      case 'knee plank':
        return Icons.horizontal_rule;
      case 'jumping jacks':
      case 'star jumps':
      case 'tuck jumps':
        return Icons.sports_martial_arts;
      case 'mountain climbers':
      case 'mountain climbers (timed)':
      case 'bear crawl':
        return Icons.terrain;
      case 'burpees':
      case 'inchworms':
      case 'supermans':
      case 'superman hold':
        return Icons.sports_kabaddi;
      case 'high knees':
      case 'high knees (timed)':
      case 'butt kicks':
      case 'jog in place':
        return Icons.directions_run;
      case 'tricep dips':
      case 'hip thrusts':
      case 'glute bridges':
      case 'hip bridge hold':
        return Icons.accessible_forward;
      case 'standing calf raises':
        return Icons.directions_walk;
      case 'donkey kicks':
      case 'bird dog hold':
        return Icons.pets;
      case 'arm circles':
        return Icons.loop;
      case 'shadow boxing':
        return Icons.sports_mma;
      case 'jump rope (imaginary)':
        return Icons.sports;
      case 'single leg balance (left)':
      case 'single leg balance (right)':
        return Icons.accessibility;
      case 'wall sit':
        return Icons.event_seat;
      case 'side lying leg raise hold (left)':
      case 'side lying leg raise hold (right)':
        return Icons.airline_seat_legroom_extra;
      case 'inchworms':
        return Icons.bug_report;
      case 'crab hold':
        return Icons.airline_seat_recline_extra;
      case 'l-sit hold (on floor or chairs)':
        return Icons.event;
      default:
        return Icons.sports_gymnastics;
    }
  }

  /// Custom animated dialog (pop effect)
  Future<T?> showAnimatedDialog<T>(BuildContext context, Widget child) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Edit Goal",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => child,
      transitionBuilder: (context, anim1, anim2, widget) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: widget,
          ),
        );
      },
    );
  }

  void editGoal(String name) async {
    TextEditingController controller =
        TextEditingController(text: exerciseGoals[name].toString());

    final updated = await showAnimatedDialog<int>(
      context,
      AlertDialog(
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
    String today = DateFormat('d').format(DateTime.now());
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
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  today,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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

  Widget buildHeading() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, _) {
        final userName = avatarProvider.userName;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
              const SizedBox(height: 0),
            ],
          ),
        );
      },
    );
  }

  Widget buildMusicLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: 0.0,
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
          _isMusicSearching
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: (val) =>
                          setState(() => _musicSearchText = val),
                      decoration: InputDecoration(
                        hintText: "Search songs...",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isMusicSearching = false;
                              _musicSearchText = "";
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Iconsax.search_normal_1_copy),
                  onPressed: () => setState(() => _isMusicSearching = true),
                  tooltip: "Search songs",
                ),
        ],
      ),
    );
  }

  Widget buildContentArea() {
    switch (selectedPill) {
      case SelectedPill.connection:
        return Expanded(
          child: FadeTransition(
            opacity: _pillAnim,
            child: ExerciseList(
              goalExercises: goalExercises,
              stopwatchExercises: stopwatchExercises,
              exerciseGoals: exerciseGoals,
              onEditGoal: editGoal,
              getExerciseIcon: getExerciseIcon,
            ),
          ),
        );
      case SelectedPill.status:
        return Expanded(
          child: FadeTransition(
            opacity: _pillAnim,
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
            opacity: _pillAnim,
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 0),
              child: Column(
                children: [
                  buildMusicLibrary(),
                  const SizedBox(height: 0),
                  Expanded(
                    child: MusicTab(
                      onSongPlayed: () => setState(() {}),
                      searchText: _musicSearchText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopBar(),
              buildHeading(),
              buildPills(),
              buildContentArea(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: !isKeyboardOpen
                ? SizedBox(
                    height: 80,
                    child: MusicBar(
                      audioPlayer: AudioService.audioPlayer,
                      getAlbumArt: getAlbumArt,
                    ),
                  )
                : const SizedBox()),
      ),
    );
  }
}

class _PillMeta {
  final String label;
  final SelectedPill pill;
  final IconData icon;
  const _PillMeta(this.label, this.pill, this.icon);
}
