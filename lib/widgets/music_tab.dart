import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_firstapp/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicTab extends StatefulWidget {
  final VoidCallback onSongPlayed;
  const MusicTab({super.key, required this.onSongPlayed});

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
            .map((song) => AudioSource.uri(Uri.parse(song.uri!)))
            .toList());
  }

  void _playSong(int index) async {
    if (AudioService.playlist == null) return;

    final isSameSong = AudioService.currentSong?.id == _songs[index].id;
    final isPlaying = AudioService.audioPlayer.playing;

    if (isSameSong) {
      if (isPlaying) {
        await AudioService.audioPlayer.pause();
      } else {
        await AudioService.audioPlayer.play();
      }
    } else {
      try {
        AudioService.currentSong = _songs[index];
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Builder(builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_permissionGranted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Permission Required",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _requestPermissionAndFetchSongs,
                    child: const Text("Grant Permission"),
                  )
                ],
              ),
            );
          }
          if (_songs.isEmpty) {
            return const Center(
                child: Text("No songs found.",
                    style: TextStyle(color: Colors.white)));
          }

          return StreamBuilder<int?>(
              stream: AudioService.audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                final currentIndex = snapshot.data;
                final isPlaying = AudioService.audioPlayer.playing;

                if (currentIndex != null && currentIndex < _songs.length) {
                  AudioService.currentSong = _songs[currentIndex];
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final isCurrentSong =
                        AudioService.currentSong?.id == song.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrentSong
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentSong
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 1.3,
                        ),
                        boxShadow: [
                          if (isCurrentSong)
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.07),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Container(
                              width: 48,
                              height: 48,
                              color: const Color(0xFF232323),
                              child: const Icon(Iconsax.musicnote,
                                  color: Colors.grey, size: 26),
                            ),
                            artworkWidth: 48,
                            artworkHeight: 48,
                          ),
                        ),
                        title: Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isCurrentSong
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 16,
                            )),
                        subtitle: Text(song.artist ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white70,
                              fontWeight: isCurrentSong
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            )),
                        trailing: GestureDetector(
                          onTap: () => _playSong(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFF232323),
                              boxShadow: [
                                if (isCurrentSong)
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              isCurrentSong && isPlaying
                                  ? Iconsax.pause
                                  : Iconsax.play,
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        onTap: () => _playSong(index),
                      ),
                    );
                  },
                );
              });
        }),
      ),
    );
  }
}
