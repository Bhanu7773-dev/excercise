import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/avatar_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme_provider.dart';

class EditAvatarPage extends StatefulWidget {
  const EditAvatarPage({super.key});
  @override
  State<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AvatarProvider>(context, listen: false);
      provider.loadUserName().then((_) {
        _nameController.text = provider.userName ?? "";
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      Provider.of<AvatarProvider>(context, listen: false)
          .setAvatar(File(picked.path));
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarFile = context.watch<AvatarProvider>().avatarFile;

    // This is the only correct way to check effective theme in Flutter!
    final brightness = Theme.of(context).colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    // Optionally, if you want to rebuild on theme changes (including system mode):
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
      body: Stack(
        children: [
          // Animated Wavy Background (TOP ONLY!)
          SizedBox(
            width: double.infinity,
            height: 270,
            child: AnimatedBuilder(
              key: ValueKey(themeMode), // ensures repaint on theme change!
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MultiWavyBackgroundPainter(
                    animationValue: _waveController.value,
                    isDark: isDark,
                  ),
                  size: Size(MediaQuery.of(context).size.width, 270),
                );
              },
            ),
          ),
          // Main content
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 72, bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with animated ring and overlays
                  Hero(
                    tag: 'profile-avatar',
                    child: Material(
                      color: Colors.transparent,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Animated ring
                              CustomPaint(
                                size: const Size(132, 132),
                                painter: _AnimatedAvatarRingPainter(
                                  animationValue: _waveController.value,
                                  isDark: isDark,
                                ),
                              ),
                              // Avatar
                              CircleAvatar(
                                radius: 58,
                                backgroundColor:
                                    isDark ? Colors.black : Colors.grey[100],
                                backgroundImage: avatarFile != null
                                    ? FileImage(avatarFile)
                                    : null,
                                child: avatarFile == null
                                    ? Icon(Icons.person_outline,
                                        size: 60,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black38)
                                    : null,
                              ),
                              // Edit icon overlay (bottom right)
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _pickAvatar(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(7),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 19),
                                  ),
                                ),
                              ),
                              // Remove icon overlay (bottom left)
                              Positioned(
                                bottom: 0,
                                left: 4,
                                child: GestureDetector(
                                  onTap: () => Provider.of<AvatarProvider>(
                                          context,
                                          listen: false)
                                      .removeAvatar(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red[700],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(7),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.white, size: 19),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Card with name field and accent
                  Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 22),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.18),
                          width: 1.4),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter your name",
                              hintStyle: TextStyle(
                                  color:
                                      isDark ? Colors.white38 : Colors.black26,
                                  fontSize: 19),
                            ),
                            onChanged: (value) {
                              Provider.of<AvatarProvider>(context,
                                      listen: false)
                                  .setUserName(value.trim());
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _nameController.text.trim().isNotEmpty
                              ? Text(
                                  'Hello, ${_nameController.text.trim()}!',
                                  key: ValueKey(_nameController.text.trim()),
                                  style: const TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your profile is only visible to you. Update your name and avatar for a personal touch!",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.55)
                                : Colors.black54,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Developer info section with social links
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.13),
                            width: 1),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                const AssetImage('assets/image/dev_avatar.png'),
                            radius: 24,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '🌑 I am DARK 🌑',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BCA Student & Aspiring Developer',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Hope you're enjoying my FIT-X app!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF6366F1),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Special thanks to our amazing collaborators:\n'
                            'ineffable & darkx dev',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '"Code, Create, Conquer!"',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amberAccent,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // GitHub
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.github,
                                    color: Colors.black),
                                onPressed: () {
                                  _launchURL(
                                      "https://github.com/Bhanu7773-dev");
                                },
                              ),
                              // Telegram (replace LinkedIn)
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.telegram,
                                    color: Color(0xFF29A7DF)),
                                onPressed: () {
                                  _launchURL("https://t.me/darkdevil7773");
                                },
                              ),
                              // Instagram
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.instagram,
                                    color: Colors.pinkAccent),
                                onPressed: () {
                                  _launchURL(
                                      "https://www.instagram.com/bhanu.pratap__7773?igsh=MWZoM2w5NTZqeHc2NQ==");
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'App Version: 1.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 15,
            child: Material(
              shape: const CircleBorder(),
              color: isDark
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
              elevation: 2,
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Multi-layer wavy animated background painter (TOP ONLY)
class MultiWavyBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  MultiWavyBackgroundPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxHeight = size.height;

    // Layer 1: Main deep wave
    final Paint paint1 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF181A20),
                const Color(0xFF232946),
                const Color(0xFF6366F1),
              ]
            : [
                const Color(0xFFF8F9FF),
                const Color(0xFF9B5DE5),
                const Color(0xFF64B5F6),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path1 = Path();
    double y1(double x) =>
        maxHeight * 0.54 +
        22 * sin((x / size.width * 2 * pi) + (animationValue * 2 * pi));
    path1.moveTo(0, y1(0));
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(i, y1(i));
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2: Shallow accent wave
    final Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF6366F1).withOpacity(0.5),
                const Color(0xFF232946).withOpacity(0.5)
              ]
            : [
                const Color(0xFF9B5DE5).withOpacity(0.4),
                const Color(0xFF64B5F6).withOpacity(0.3)
              ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path2 = Path();
    double y2(double x) =>
        maxHeight * 0.68 +
        12 *
            cos((x / size.width * 2 * pi) + (animationValue * 2 * pi) + pi / 2);
    path2.moveTo(0, y2(0));
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(i, y2(i));
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3: Soft highlight wave
    final Paint paint3 = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
            : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxHeight));
    final Path path3 = Path();
    double y3(double x) =>
        maxHeight * 0.39 +
        10 * sin((x / size.width * 2 * pi) - (animationValue * 2 * pi));
    path3.moveTo(0, y3(0));
    for (double i = 0; i <= size.width; i++) {
      path3.lineTo(i, y3(i));
    }
    path3.lineTo(size.width, 0);
    path3.lineTo(0, 0);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant MultiWavyBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isDark != isDark;
}

// Animated Avatar Ring Painter (syncs with background animation)
class _AnimatedAvatarRingPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  _AnimatedAvatarRingPainter(
      {required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2 - 4;
    final double ringWidth = 7.0;

    // Main animated color ring
    final rect =
        Rect.fromCircle(center: Offset(center, center), radius: radius);
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: isDark
          ? [
              const Color(0xFF6366F1),
              Colors.deepPurpleAccent,
              const Color(0xFF6366F1),
            ]
          : [
              const Color(0xFF9B5DE5),
              Colors.purpleAccent,
              const Color(0xFF9B5DE5),
            ],
      stops: [
        0.0,
        0.5 + 0.2 * sin(animationValue * 2 * pi),
        1.0,
      ],
      transform: GradientRotation(animationValue * 2 * pi),
    );
    final Paint ringPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(center, center), radius, ringPaint);

    // Add pulsating glow
    final glowPaint = Paint()
      ..color = (isDark ? const Color(0xFF6366F1) : const Color(0xFF9B5DE5))
          .withOpacity(0.18 + 0.10 * sin(animationValue * 2 * pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(center, center),
        radius + 4 + 2 * sin(animationValue * 2 * pi), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedAvatarRingPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isDark != isDark;
}
