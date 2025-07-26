import 'package:flutter/material.dart';
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
    try {
      AudioService.currentSong = _songs[index];
      widget.onSongPlayed();
      await AudioService.audioPlayer.setAudioSource(AudioService.playlist!, initialIndex: index);
      await AudioService.audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing song: $e");
    }
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
                child: Text("No songs found.", style: TextStyle(color: Colors.white)));
          }
          return StreamBuilder<PlayerState>(
            stream: AudioService.audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isPlaying = playerState?.playing ?? false;
              
              return ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final song = _songs[index];
                  final isCurrentSong = AudioService.currentSong?.id == song.id;

                  return ListTile(
                    leading: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget:
                          const Icon(Icons.music_note, color: Colors.grey),
                    ),
                    title: Text(song.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(song.artist ?? 'Unknown',
                        style: const TextStyle(color: Colors.white70)),
                    trailing: isCurrentSong && isPlaying
                        ? const Icon(Icons.pause_circle_filled, color: Colors.white, size: 30)
                        : const Icon(Icons.play_circle_filled, color: Colors.white, size: 30),
                    onTap: () => _playSong(index),
                  );
                },
              );
            }
          );
        }),
      ),
    );
  }
}