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
      queueIndex: _currentIndex, // Fix: Use internal index, not just_audio's index (which is always 0 for single source)
    );
  }

  List<MediaItem> _queue = [];
  int _currentIndex = 0;
  bool _isShuffleMode = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    _queue = queue;
    // Broadcast queue to listeners if needed (BaseAudioHandler has 'queue' subject)
    // this.queue.add(_queue); 
  }

  Future<void> setQueue(List<MediaItem> newQueue, int initialIndex) async {
    _queue = newQueue;
    _currentIndex = initialIndex;
    queue.add(_queue); // Update behaviorsubject
    await _playCurrentIndex();
  }

  Future<void> _playCurrentIndex() async {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) return;
    final item = _queue[_currentIndex];
    
    // Update MediaItem for notification
    mediaItem.add(item);
    
    // Play with just_audio
    final uri = item.extras?['uri'] as String?;
    if (uri != null) {
      try {
        await _player.setAudioSource(AudioSource.uri(
          Uri.parse(uri),
          tag: item, 
        ));
        _player.play(); // Don't await play() as it waits for completion
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
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
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    int nextIndex;
    if (_isShuffleMode) {
       // Simple shuffle logic: random index
       // Ideally we should have a shuffled list map, but for now random selection
       nextIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length);
       // Avoid repeating same song if possible
       if (_queue.length > 1 && nextIndex == _currentIndex) {
          nextIndex = (nextIndex + 1) % _queue.length;
       }
    } else {
       nextIndex = _currentIndex + 1;
       if (nextIndex >= _queue.length) {
         if (_loopMode == LoopMode.all) {
           nextIndex = 0;
         } else {
           // End of queue
           await pause();
           await seek(Duration.zero);
           return;
         }
       }
    }
    
    _currentIndex = nextIndex;
    await _playCurrentIndex();
    // Notify listeners via controller? No, now we handle it internally.
    // But PlayerBloc might still be listening to skipping stream. 
    // We should probably KEEP the stream for now so Bloc can update its UI state (index)
    // OR Bloc should listen to mediaItem change to know song changed.
    _skipToNextController.add(null);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    
    // If we are far into the song, restart it
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (_isShuffleMode) {
       // Random again? Or we need history? 
       // For simple shuffle without history, random is expected or previous in list?
       // Usually 'Previous' in shuffle goes to previously played song (History).
       // Implementing full history is complex. 
       // Fallback: Previous track in list or random? 
       // Let's rely on standard: Previous calls usually go back in sequential order or restart.
       // User usually expects restart.
       prevIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length);
    } else {
       prevIndex = _currentIndex - 1;
       if (prevIndex < 0) {
         prevIndex = _queue.length - 1; // Wrap or stop? usually wrap or stay at 0
       }
    }

    _currentIndex = prevIndex;
    await _playCurrentIndex();
    _skipToPreviousController.add(null); 
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _playCurrentIndex();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _isShuffleMode = shuffleMode == AudioServiceShuffleMode.all || shuffleMode == AudioServiceShuffleMode.group;
    // Notify just_audio if it supports it, or just handle internally
    await _player.setShuffleModeEnabled(_isShuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _loopMode = LoopMode.off;
        break;
      case AudioServiceRepeatMode.one:
        _loopMode = LoopMode.one;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        _loopMode = LoopMode.all;
        break;
    }
    await _player.setLoopMode(_loopMode);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
      _loopMode = mode;
      await _player.setLoopMode(mode);
  }

  // Legacy support
  Future<void> playSong(String uri, String title, String artist, String? artUri, int id) async {
      // Just wrap in a single item queue
      final item = MediaItem(
        id: id.toString(),
        album: "Unknown Album",
        title: title,
        artist: artist,
        duration: _player.duration, 
        artUri: artUri != null ? Uri.parse(artUri) : null,
        extras: {'uri': uri},
      );
      await setQueue([item], 0);
  }
}
