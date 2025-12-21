import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // _player.mediaItemStream.pipe(mediaItem); // Not available in just_audio basic
    
    // Listen to player state to update notification button states
    _player.playerStateStream.listen((state) {
      // _transformEvent handles most, but we might need explicit updates for processing state if needed
    });
  }
  
  // Expose player for internal use (or wrap streams)
  AudioPlayer get internalPlayer => _player;

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  final _skipToNextController = StreamController<void>.broadcast();
  Stream<void> get skipToNextStream => _skipToNextController.stream;

  final _skipToPreviousController = StreamController<void>.broadcast();
  Stream<void> get skipToPreviousStream => _skipToPreviousController.stream;

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() {
    _skipToNextController.add(null);
    return super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() {
    _skipToPreviousController.add(null);
    return super.skipToPrevious();
  }

  // We will need to map custom Song entity to MediaItem when playing
  Future<void> playSong(String uri, String title, String artist, String? artUri, int id) async {
    // Update MediaItem for notification
    final item = MediaItem(
      id: id.toString(),
      album: "Unknown Album",
      title: title,
      artist: artist,
      duration: _player.duration, 
      artUri: artUri != null ? Uri.parse(artUri) : null,
      extras: {'uri': uri}, // Store URI in extras
    );
    mediaItem.add(item);
    
    await _player.setAudioSource(AudioSource.uri(
      Uri.parse(uri),
         tag: item, // Just Audio tag
    ));
    await _player.play();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }
}
