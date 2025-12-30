import 'package:injectable/injectable.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_handler.dart';

abstract class AudioPlayerService {
  Future<void> setUrl(String url, {String? title, String? artist, String? artUri, int? id});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setLoopMode(LoopMode mode);
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlayerState> get playerStateStream;
  Stream<void> get skipToNextStream;
  Stream<void> get skipToPreviousStream;
  Future<int?> getAudioSessionId();
}

@LazySingleton(as: AudioPlayerService)
class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioHandler _audioHandler;

  AudioPlayerServiceImpl(this._audioHandler);

  // Helper to access internal player for streams if needed, 
  // or we can map AudioHandler streams.
  // For simplicity and matching existing streams:
  AudioPlayer get _player => (_audioHandler as AudioPlayerHandler).internalPlayer;

  @override
  Future<void> setUrl(String url, {String? title, String? artist, String? artUri, int? id}) async {
    await (_audioHandler as AudioPlayerHandler).playSong(
      url, 
      title ?? "Unknown Title", 
      artist ?? "Unknown Artist", 
      artUri,
      id ?? 0,
    ); 
  }

  @override
  Future<void> play() => _audioHandler.play();

  @override
  Future<void> pause() => _audioHandler.pause();

  @override
  Future<void> seek(Duration position) => _audioHandler.seek(position);

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    await (_audioHandler as AudioPlayerHandler).setLoopMode(mode);
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<void> get skipToNextStream => (_audioHandler as AudioPlayerHandler).skipToNextStream;

  @override
  Stream<void> get skipToPreviousStream => (_audioHandler as AudioPlayerHandler).skipToPreviousStream;

  @override
  Future<int?> getAudioSessionId() async {
    return (_audioHandler as AudioPlayerHandler).internalPlayer.androidAudioSessionId;
  }
}
