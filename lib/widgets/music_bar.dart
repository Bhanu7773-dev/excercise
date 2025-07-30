import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_firstapp/widgets/wavy_progress_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicBar extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final Future<Uint8List?> Function(int songId) getAlbumArt;

  const MusicBar({
    super.key,
    required this.audioPlayer,
    required this.getAlbumArt,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = audioPlayer.currentIndex;
    final sequence = audioPlayer.sequence;
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Stack(
            children: [
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
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
                    onTap: () => audioPlayer.stop(),
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
    // Using LayoutBuilder to get the available constraints and prevent overflows.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column for Song Title and Artist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.25, // Relative height
                    child: Marquee(
                      text: song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
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
                      shadows: const [Shadow(blurRadius: 2.0, color: Colors.black54)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // Row for Progress Bar and Controls
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: constraints.maxHeight * 0.3, // Relative height
                      child: StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = audioPlayer.duration ?? Duration.zero;
                          return WavyProgressBar(
                            progress: (duration.inMilliseconds > 0)
                                ? position.inMilliseconds / duration.inMilliseconds
                                : 0.0,
                            waveColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.3),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Playback Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 22,
                        splashRadius: 20,
                        icon: const Icon(Iconsax.previous, color: Colors.white),
                        onPressed: () => audioPlayer.seekToPrevious(),
                      ),
                      // The wrapping container has been removed.
                      IconButton(
                        iconSize: 30, // Made icon slightly larger
                        splashRadius: 24,
                        icon: Icon(
                          isPlaying ? Iconsax.pause : Iconsax.play,
                          color: Colors.white, // Icon color is now white
                        ),
                        onPressed: () => isPlaying ? audioPlayer.pause() : audioPlayer.play(),
                      ),
                      IconButton(
                        iconSize: 22,
                        splashRadius: 20,
                        icon: const Icon(Iconsax.next, color: Colors.white),
                        onPressed: () => audioPlayer.seekToNext(),
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
