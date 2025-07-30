import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/avatar_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EditAvatarPage extends StatefulWidget {
  const EditAvatarPage({super.key});
  @override
  State<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AvatarProvider>(context, listen: false);
      provider.loadUserName().then((_) {
        _nameController.text = provider.userName ?? "";
        setState(() {});
      });
    });
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open $url")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarFile = context.watch<AvatarProvider>().avatarFile;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // App Themed Gradient Background with a wavy overlay
          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavyBackgroundPainter(
                primaryColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
              ),
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
                  // Avatar with theme accent border and edit/remove overlays
                  Hero(
                    tag: 'profile-avatar',
                    child: Material(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.surfaceVariant,
                                  colorScheme.surfaceVariant,
                                  colorScheme.primary,
                                ],
                                stops: const [0, 0.5, 0.85, 1],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 62,
                              backgroundColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: 58,
                                backgroundColor: colorScheme.surface,
                                backgroundImage: avatarFile != null
                                    ? FileImage(avatarFile)
                                    : null,
                                child: avatarFile == null
                                    ? Icon(Icons.person_outline,
                                        size: 60,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.5))
                                    : null,
                              ),
                            ),
                          ),
                          // Edit icon overlay (bottom right)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _pickAvatar(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: colorScheme.onPrimary, width: 2),
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Icon(Icons.edit,
                                    color: colorScheme.onPrimary, size: 19),
                              ),
                            ),
                          ),
                          // Remove icon overlay (bottom left)
                          Positioned(
                            bottom: 0,
                            left: 4,
                            child: GestureDetector(
                              onTap: () => Provider.of<AvatarProvider>(context,
                                      listen: false)
                                  .removeAvatar(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: colorScheme.onError, width: 2),
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Icon(Icons.delete_outline,
                                    color: colorScheme.onError, size: 19),
                              ),
                            ),
                          ),
                        ],
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
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.18),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                          color: colorScheme.primary.withOpacity(0.32),
                          width: 1.4),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter your name",
                              hintStyle: TextStyle(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.4),
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
                                  style: TextStyle(
                                    color: colorScheme.primary,
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
                            color: colorScheme.onSurface.withOpacity(0.6),
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
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: colorScheme.primary.withOpacity(0.23),
                            width: 1),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/image/dev_avatar.png'),
                            radius: 24,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '🌑 I am DARK 🌑',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorScheme.onSurface,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BCA Student & Aspiring Developer',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Hope you're enjoying my FIT-X app!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Special thanks to our amazing collaborators:\n'
                            'ineffable & darkx dev',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '"Code, Create, Conquer!"',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber, // Kept for specific accent
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
                                icon: Icon(FontAwesomeIcons.github,
                                    color: colorScheme.onSurface),
                                onPressed: () {
                                  _launchURL(
                                      "https://github.com/Bhanu7773-dev");
                                },
                              ),
                              // Telegram
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
                              color: colorScheme.onSurface.withOpacity(0.4),
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
              color: colorScheme.background.withOpacity(0.7),
              elevation: 2,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Wavy Background with FIT-X theme
class _WavyBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _WavyBackgroundPainter(
      {required this.primaryColor, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Main accent wave
    Paint paint = Paint()..color = primaryColor;
    Path path = Path();
    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Overlay for depth
    Paint overlay = Paint()..color = backgroundColor.withOpacity(0.85);
    Path overlayPath = Path();
    overlayPath.lineTo(0, size.height * 0.38);
    overlayPath.quadraticBezierTo(size.width * 0.3, size.height * 0.66,
        size.width * 0.5, size.height * 0.5);
    overlayPath.quadraticBezierTo(
        size.width * 0.7, size.height * 0.32, size.width, size.height * 0.62);
    overlayPath.lineTo(size.width, 0);
    overlayPath.close();
    canvas.drawPath(overlayPath, overlay);
  }

  @override
  bool shouldRepaint(covariant _WavyBackgroundPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
