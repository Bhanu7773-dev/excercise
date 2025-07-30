import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_firstapp/utils/audio_utils.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicTab extends StatefulWidget {
  final VoidCallback onSongPlayed;
  final String searchText;

  const MusicTab({
    super.key,
    required this.onSongPlayed,
    required this.searchText,
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
    _buildPlaylist(songs);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  void _buildPlaylist(List<SongModel> songs) {
    AudioService.playlist = ConcatenatingAudioSource(
      children: songs
          .where((song) => song.uri != null)
          .map((song) => AudioSource.uri(
                Uri.parse(song.uri!),
                tag: song,
              ))
          .toList(),
    );
  }

  void _playSong(int index) async {
    if (AudioService.playlist == null) return;

    final isSameSong = AudioService.audioPlayer.sequence != null &&
        AudioService.audioPlayer.currentIndex == index;
    final isPlaying = AudioService.audioPlayer.playing;

    if (isSameSong) {
      if (isPlaying) {
        await AudioService.audioPlayer.pause();
      } else {
        await AudioService.audioPlayer.play();
      }
    } else {
      try {
        widget.onSongPlayed();
        await AudioService.audioPlayer
            .setAudioSource(AudioService.playlist!, initialIndex: index);
        await AudioService.audioPlayer.play();
      } catch (e) {
        debugPrint("Error playing song: $e");
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  List<SongModel> get _filteredSongs {
    if (widget.searchText.isEmpty) return _songs;
    final text = widget.searchText.toLowerCase();
    return _songs.where((song) {
      final title = song.title.toLowerCase();
      final artist = (song.artist ?? '').toLowerCase();
      return title.contains(text) || artist.contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Builder(builder: (context) {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (!_permissionGranted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Permission Required",
                    style: TextStyle(color: colorScheme.onBackground, fontSize: 18)),
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
        if (_filteredSongs.isEmpty) {
          return Center(
              child: Text("No songs found.",
                  style: TextStyle(color: colorScheme.onBackground)));
        }

        return StreamBuilder<int?>(
            stream: AudioService.audioPlayer.currentIndexStream,
            builder: (context, snapshot) {
              final currentIndex = snapshot.data;
              final isPlaying = AudioService.audioPlayer.playing;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  final realIndex = _songs.indexWhere((s) => s.id == song.id);
                  bool isCurrentSong = false;
                  final sequence = AudioService.audioPlayer.sequence;
                  if (currentIndex != null &&
                      sequence != null &&
                      currentIndex >= 0 &&
                      currentIndex < sequence.length) {
                    final tag = sequence[currentIndex].tag;
                    if (tag is SongModel && tag.id == song.id) {
                      isCurrentSong = true;
                    }
                  }

                  return AnimatedContainer(
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
                                color: colorScheme.onSurface.withOpacity(0.5), size: 18),
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
                      trailing: GestureDetector(
                        onTap: () => _playSong(realIndex),
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
                                  color: colorScheme.primary.withOpacity(0.18),
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
                      onTap: () => _playSong(realIndex),
                    ),
                  );
                },
              );
            });
      }),
    );
  }
}
