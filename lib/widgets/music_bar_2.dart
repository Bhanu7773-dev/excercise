import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicBar2 extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final Future<Uint8List?> Function(int songId) getAlbumArt;

  const MusicBar2({
    super.key,
    required this.audioPlayer,
    required this.getAlbumArt,
  });

  @override
  Widget build(BuildContext context) {
    // Use currentIndexStream and access audioPlayer.sequence with .tag as SongModel
    return StreamBuilder<int?>(
      stream: audioPlayer.currentIndexStream,
      builder: (context, snapshot) {
        final currentIndex = snapshot.data;
        final sequence = audioPlayer.sequence;
        SongModel? currentSong;

        if (currentIndex != null &&
            currentIndex >= 0 &&
            currentIndex < sequence.length) {
          final tag = sequence[currentIndex].tag;
          if (tag is SongModel) {
            currentSong = tag;
          }
        }

        if (currentSong == null) return const SizedBox.shrink();

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: StreamBuilder<PlayerState>(
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
            ),
          ),
        );
      },
    );
  }

  Widget loadingWidget(BuildContext context) => Container(
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

  Widget musicControlWidget(
      BuildContext context, bool isPlaying, SongModel song) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          FutureBuilder<Uint8List?>(
            future: getAlbumArt(song.id),
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
                onPressed: () => audioPlayer.seekToPrevious(),
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
                    isPlaying ? audioPlayer.pause() : audioPlayer.play();
                  },
                ),
              ),
              IconButton(
                iconSize: 20,
                icon: Icon(
                  Iconsax.next,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => audioPlayer.seekToNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
