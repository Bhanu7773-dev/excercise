import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
// Make sure this path is correct for your project structure
import 'package:my_firstapp/widgets/wavy_progress_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// A custom painter that draws a series of expanding, fading circles to create a wave pulse effect.
class WavePulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int waveCount;

  WavePulsePainter({
    required this.progress,
    required this.color,
    this.waveCount = 3, // Draw 3 waves for a smoother effect
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius = size.width * 0.8; // Cap the max radius of a wave

    // Define the properties for the glowing paint
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw multiple waves
    for (int i = 0; i < waveCount; i++) {
      // Stagger the start of each wave
      final double waveProgress = (progress + (i / waveCount)) % 1.0;

      // As progress goes from 0 to 1, the radius expands and opacity fades
      final double currentRadius = maxRadius * waveProgress;
      final double opacity = 1.0 - waveProgress;

      // Don't draw fully faded waves
      if (opacity <= 0) continue;

      paint.color = color.withOpacity(opacity);

      // The blur creates the "glow" effect
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + (waveProgress * 4));

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WavePulsePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

//---

class MusicBar extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Future<Uint8List?> Function(int songId) getAlbumArt;

  const MusicBar({
    super.key,
    required this.audioPlayer,
    required this.getAlbumArt,
  });

  @override
  State<MusicBar> createState() => _MusicBarState();
}

class _MusicBarState extends State<MusicBar> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Slower, more graceful wave
      vsync: this,
    )..repeat(); // Use repeat(), not repeat(reverse: true)

    // A simple linear animation from 0.0 to 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.audioPlayer.currentIndex;
    final sequence = widget.audioPlayer.sequence;
    SongModel? currentSong;

    if (currentIndex != null &&
        sequence != null &&
        currentIndex >= 0 &&
        currentIndex < sequence.length) {
      final tag = sequence[currentIndex].tag;
      if (tag is SongModel) {
        currentSong = tag;
      }
    }

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // LAYER 1: Album art background
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: FutureBuilder<Uint8List?>(
              future: widget.getAlbumArt(currentSong.id),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
                return Container(color: Colors.grey.shade800);
              },
            ),
          ),
        ),

        // LAYER 2: The glowing wave pulse effect ✨
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePulsePainter(
                    progress: _animation.value,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                );
              },
            ),
          ),
        ),

        // LAYER 3: The blur and UI controls
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
              ),
              child: Stack(
                children: [
                  StreamBuilder<PlayerState>(
                    stream: widget.audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final isPlaying = playerState?.playing ?? false;
                      final processingState = playerState?.processingState;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return loadingWidget(context);
                      }
                      return musicControlWidget(context, isPlaying, currentSong!);
                    },
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => widget.audioPlayer.stop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget loadingWidget(BuildContext context) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        ),
      );

  Widget musicControlWidget(
      BuildContext context, bool isPlaying, SongModel song) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.25,
                    child: Marquee(
                      text: song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        shadows: [
                          Shadow(blurRadius: 1.5, color: Colors.black54)
                        ],
                      ),
                      blankSpace: 50,
                      velocity: 30,
                    ),
                  ),
                  Text(
                    song.artist ?? "Unknown Artist",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      shadows: const [
                        Shadow(blurRadius: 2.0, color: Colors.black54)
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: constraints.maxHeight * 0.3,
                      child: StreamBuilder<Duration>(
                        stream: widget.audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration =
                              widget.audioPlayer.duration ?? Duration.zero;
                          return WavyProgressBar(
                            progress: (duration.inMilliseconds > 0)
                                ? position.inMilliseconds /
                                    duration.inMilliseconds
                                : 0.0,
                            waveColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.3),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 22,
                        splashRadius: 20,
                        icon:
                            const Icon(Iconsax.previous, color: Colors.white),
                        onPressed: () => widget.audioPlayer.seekToPrevious(),
                      ),
                      IconButton(
                        iconSize: 30,
                        splashRadius: 24,
                        icon: Icon(
                          isPlaying ? Iconsax.pause : Iconsax.play,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            isPlaying ? widget.audioPlayer.pause() : widget.audioPlayer.play(),
                      ),
                      IconButton(
                        iconSize: 22,
                        splashRadius: 20,
                        icon: const Icon(Iconsax.next, color: Colors.white),
                        onPressed: () => widget.audioPlayer.seekToNext(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}