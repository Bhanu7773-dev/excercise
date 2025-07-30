import 'dart:typed_data';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer audioPlayer = AudioPlayer();
  static SongModel? currentSong;
  static ConcatenatingAudioSource? playlist;
}

Future<Uint8List?> getAlbumArt(int songId) async {
  final OnAudioQuery query = OnAudioQuery();
  bool permission = await query.permissionsStatus();
  if (!permission) await query.permissionsRequest();
  return await query.queryArtwork(
    songId,
    ArtworkType.AUDIO,
  );
}
