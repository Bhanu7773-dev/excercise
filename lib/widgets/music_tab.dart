import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_firstapp/utils/audio_utils.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

// Only define MusicListMode HERE and import this file wherever you need it
enum MusicListMode { all, favorite, blocked }

class MusicTab extends StatefulWidget {
  final VoidCallback onSongPlayed;
  final String searchText;
  final MusicListMode mode;
  final Set<int> favoriteSongIds;
  final Set<int> blockedSongIds;
  final Future<void> Function(int) onFavoriteToggle;
  final Future<void> Function(int) onBlock;
  final Future<void> Function(int) onUnblock;

  const MusicTab({
    super.key,
    required this.onSongPlayed,
    required this.searchText,
    required this.mode,
    required this.favoriteSongIds,
    required this.blockedSongIds,
    required this.onFavoriteToggle,
    required this.onBlock,
    required this.onUnblock,
  });

  @override
  State<MusicTab> createState() => _MusicTabState();
}

class _MusicTabState extends State<MusicTab> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _permissionGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchSongs();
  }

  Future<void> _requestPermissionAndFetchSongs() async {
    var status = await Permission.audio.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      await _fetchSongs();
    } else {
      setState(() {
        _permissionGranted = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSongs() async {
    if (!_permissionGranted) return;
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  Future<void> _playOrPauseSong(int index, List<SongModel> filtered) async {
    final audioPlayer = AudioService.audioPlayer;
    final currentIndex = audioPlayer.currentIndex;
    final sequence = audioPlayer.sequence;
    final currentTag = (sequence != null &&
            currentIndex != null &&
            currentIndex >= 0 &&
            currentIndex < sequence.length)
        ? sequence[currentIndex].tag
        : null;

    final selectedSong = filtered[index];

    // If the currently playing song is the selected one
    if (currentTag is SongModel && currentTag.id == selectedSong.id) {
      if (audioPlayer.playing) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
      setState(() {});
      return;
    }

    // Otherwise, start the playlist from selected song
    final playlist = ConcatenatingAudioSource(
      children: filtered
          .where((song) => song.uri != null)
          .map((song) => AudioSource.uri(
                Uri.parse(song.uri!),
                tag: song,
              ))
          .toList(),
    );
    try {
      widget.onSongPlayed();
      await audioPlayer.setAudioSource(playlist, initialIndex: index);
      await audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing song: $e");
    }
    if (!mounted) return;
    setState(() {});
  }

  List<SongModel> get _filteredSongs {
    List<SongModel> base = _songs
        .where((song) => !widget.blockedSongIds.contains(song.id))
        .toList();
    if (widget.mode == MusicListMode.favorite) {
      base = base
          .where((song) => widget.favoriteSongIds.contains(song.id))
          .toList();
    } else if (widget.mode == MusicListMode.blocked) {
      base = _songs
          .where((song) => widget.blockedSongIds.contains(song.id))
          .toList();
    }
    if (widget.searchText.isNotEmpty) {
      final text = widget.searchText.toLowerCase();
      base = base.where((song) {
        final title = song.title.toLowerCase();
        final artist = (song.artist ?? '').toLowerCase();
        return title.contains(text) || artist.contains(text);
      }).toList();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredSongs;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Builder(builder: (context) {
        if (_isLoading) {
          return Center(
              child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (!_permissionGranted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Permission Required",
                    style: TextStyle(
                        color: colorScheme.onBackground, fontSize: 18)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: _requestPermissionAndFetchSongs,
                  child: const Text("Grant Permission"),
                )
              ],
            ),
          );
        }
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              widget.mode == MusicListMode.favorite
                  ? "No songs in Playlist"
                  : widget.mode == MusicListMode.blocked
                      ? "No song blocked"
                      : "No songs found.",
              style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          );
        }

        return StreamBuilder<int?>(
            stream: AudioService.audioPlayer.currentIndexStream,
            builder: (context, snapshot) {
              final currentIndex = snapshot.data;
              final isPlaying = AudioService.audioPlayer.playing;
              final sequence = AudioService.audioPlayer.sequence;
              final tag = (sequence != null &&
                      currentIndex != null &&
                      currentIndex >= 0 &&
                      currentIndex < sequence.length)
                  ? sequence[currentIndex].tag
                  : null;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final song = filtered[index];
                  final isCurrentSong = tag is SongModel && tag.id == song.id;
                  final isFavorite = widget.favoriteSongIds.contains(song.id);

                  return Dismissible(
                    key: ValueKey(song.id.toString() +
                        (widget.mode == MusicListMode.blocked
                            ? '_blocked'
                            : widget.mode == MusicListMode.favorite
                                ? '_fav'
                                : '')),
                    confirmDismiss: (direction) async {
                      // --- Blocked Mode: swipe right to unblock and remove from list ---
                      if (widget.mode == MusicListMode.blocked) {
                        if (direction == DismissDirection.startToEnd) {
                          await widget.onUnblock(song.id);
                          setState(() {});
                          return true; // Remove from list
                        }
                        return false;
                      }
                      // --- Favorite Mode: swipe right to unfavorite and remove from list ---
                      if (widget.mode == MusicListMode.favorite) {
                        if (direction == DismissDirection.startToEnd) {
                          await widget.onFavoriteToggle(song.id);
                          setState(() {});
                          return true; // Remove from list
                        }
                        // Optionally allow block by left swipe in favorite mode
                        if (direction == DismissDirection.endToStart) {
                          await widget.onBlock(song.id);
                          setState(() {});
                          return true; // Remove from list (because now blocked, not favorite)
                        }
                        return false;
                      }
                      // --- All Mode ---
                      if (widget.mode == MusicListMode.all) {
                        if (direction == DismissDirection.startToEnd) {
                          await widget.onFavoriteToggle(song.id);
                          setState(() {});
                          return false; // Don't remove from list in all mode
                        }
                        if (direction == DismissDirection.endToStart) {
                          await widget.onBlock(song.id);
                          setState(() {});
                          return true; // Remove from list (because now blocked)
                        }
                        return false;
                      }
                      return false;
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: (widget.mode == MusicListMode.blocked)
                            ? Colors.green.withOpacity(0.85)
                            : Colors.pinkAccent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(
                        children: [
                          Icon(
                            widget.mode == MusicListMode.blocked
                                ? Icons.remove_circle_outline
                                : (widget.mode == MusicListMode.favorite
                                    ? Icons.favorite
                                    : (isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border)),
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.mode == MusicListMode.blocked
                                ? "Unblock"
                                : (widget.mode == MusicListMode.favorite
                                    ? "Remove Favorite"
                                    : (isFavorite
                                        ? "Remove Favorite"
                                        : "Favorite")),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.mode == MusicListMode.blocked
                                ? ""
                                : (widget.mode == MusicListMode.favorite
                                    ? "Block"
                                    : "Block"),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          if (widget.mode != MusicListMode.blocked)
                            SizedBox(width: 8),
                          if (widget.mode != MusicListMode.blocked)
                            Icon(Icons.block, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrentSong
                            ? colorScheme.primary.withOpacity(0.12)
                            : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrentSong
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 1.0,
                        ),
                        boxShadow: [
                          if (isCurrentSong)
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.07),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Container(
                              width: 36,
                              height: 36,
                              color: colorScheme.surface,
                              child: Icon(Iconsax.musicnote,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  size: 18),
                            ),
                            artworkWidth: 36,
                            artworkHeight: 36,
                          ),
                        ),
                        title: Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: isCurrentSong
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 13,
                            )),
                        subtitle: Text(song.artist ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentSong
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isCurrentSong
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 10,
                            )),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.mode == MusicListMode.blocked)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.green,
                                tooltip: "Unblock",
                                onPressed: () async {
                                  await widget.onUnblock(song.id);
                                  setState(() {});
                                },
                              ),
                            GestureDetector(
                              onTap: () => _playOrPauseSong(index, filtered),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrentSong
                                      ? colorScheme.primary
                                      : colorScheme.surface,
                                  boxShadow: [
                                    if (isCurrentSong)
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withOpacity(0.18),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isCurrentSong && isPlaying
                                      ? Iconsax.pause
                                      : Iconsax.play,
                                  color: isCurrentSong
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                  size: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _playOrPauseSong(index, filtered),
                      ),
                    ),
                  );
                },
              );
            });
      }),
    );
  }
}
