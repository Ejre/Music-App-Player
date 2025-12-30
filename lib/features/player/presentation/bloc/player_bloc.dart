import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart' hide PlayerEvent; // For PlayerState enum
import '../../../../features/library/domain/entities/song.dart';
import '../../data/services/audio_player_service.dart';
import 'player_event.dart';
import 'player_state.dart' as bloc_state; // Alias to avoid conflict with just_audio
import '../../domain/entities/lyric_line.dart';
import '../../data/repositories/lyrics_repository.dart';

@injectable
class PlayerBloc extends Bloc<PlayerEvent, bloc_state.PlayerState> {
  final AudioPlayerService _playerService;
  final LyricsRepository _lyricsRepository;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  StreamSubscription? _skipNextSubscription;
  StreamSubscription? _skipPreviousSubscription;

  PlayerBloc(this._playerService, this._lyricsRepository) : super(const bloc_state.PlayerState()) {
    on<PlayerPlaySong>(_onPlaySong);
    on<PlayerPause>(_onPause);
    on<PlayerResume>(_onResume);
    on<PlayerSeek>(_onSeek);
    on<PlayerNext>(_onNext);
    on<PlayerPrevious>(_onPrevious);
    on<PlayerShuffle>(_onShuffle);
    on<PlayerRepeat>(_onRepeat);
    on<PlayerSetQueue>(_onSetQueue);
    on<PlayerStateChanged>(_onPlayerStateChanged);
    on<PlayerDurationChanged>(_onDurationChanged);
    on<PlayerPositionChanged>(_onPositionChanged);
    on<SetSleepTimer>(_onSetSleepTimer);
    on<CancelSleepTimer>(_onCancelSleepTimer);

    // Listen to service streams
    _playerStateSubscription = _playerService.playerStateStream.listen((playerState) {
        bloc_state.PlayerStatus status;
        if (playerState.processingState == ProcessingState.loading || 
            playerState.processingState == ProcessingState.buffering) {
          status = bloc_state.PlayerStatus.loading;
        } else if (playerState.playing) {
          status = bloc_state.PlayerStatus.playing;
        } else {
          status = bloc_state.PlayerStatus.paused;
        }
        
        if (playerState.processingState == ProcessingState.completed) {
           add(PlayerNext());
        }

        add(PlayerStateChanged(status));

        // Lazy retry for lyrics if they are missing when we start playing
        if (status == bloc_state.PlayerStatus.playing) {
           add(PlayerCheckLyrics());
        }
    });

    _durationSubscription = _playerService.durationStream.listen((duration) {
      add(PlayerDurationChanged(duration ?? Duration.zero));
    });

    _positionSubscription = _playerService.positionStream.listen((position) {
      add(PlayerPositionChanged(position));
    });

    _skipNextSubscription = _playerService.skipToNextStream.listen((_) {
      add(PlayerNext());
    });

    _skipPreviousSubscription = _playerService.skipToPreviousStream.listen((_) {
      add(PlayerPrevious());
    });
  }
  
  Timer? _sleepTimer;

  void _onSetSleepTimer(SetSleepTimer event, Emitter<bloc_state.PlayerState> emit) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(event.duration, () {
      add(PlayerPause());
      _sleepTimer = null;
    });
    // Optionally emit state change if UI needs to show timer active
  }

  void _onCancelSleepTimer(CancelSleepTimer event, Emitter<bloc_state.PlayerState> emit) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  void _onPlayerStateChanged(PlayerStateChanged event, Emitter<bloc_state.PlayerState> emit) {
    emit(state.copyWith(status: event.status));
  }

  void _onDurationChanged(PlayerDurationChanged event, Emitter<bloc_state.PlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onPositionChanged(PlayerPositionChanged event, Emitter<bloc_state.PlayerState> emit) {
    // Update lyrics position
    LyricLine? newCurrentLine = state.currentLyricLine;
    if (state.lyrics != null && state.lyrics!.isNotEmpty) {
      final position = event.position;
      for (final line in state.lyrics!) {
         if (line.time <= position) {
            newCurrentLine = line;
         } else {
            break; 
         }
      }
    }

    if (newCurrentLine != state.currentLyricLine) {
       emit(state.copyWith(position: event.position, currentLyricLine: newCurrentLine));
    } else {
       emit(state.copyWith(position: event.position));
    }
  }

  Future<void> _onSetQueue(PlayerSetQueue event, Emitter<bloc_state.PlayerState> emit) async {
    emit(state.copyWith(queue: event.queue, currentIndex: event.initialIndex));
    add(PlayerPlaySong(event.queue[event.initialIndex]));
  }

  Future<void> _onNext(PlayerNext event, Emitter<bloc_state.PlayerState> emit) async {
    if (state.queue.isEmpty) return;

    if (state.loopMode == bloc_state.LoopMode.one) {
      // If native looping fails or we want to force it
      // replay current is logic. But just_audio handles one usually.
      // If we are here, it means we manually pressed Next. 
      // If manual Next on Repeat One, usually we go to next song or replay?
      // Standard behavior: Manual Next -> Next song. Auto completion -> Replay.
      // Since this _onNext is called by Auto Completion (via listener) AND Manual Button
      // We need to know context. But listener logic is:
      // if (playerState.processingState == ProcessingState.completed) add(PlayerNext());
      // just_audio LoopMode.one prevents 'completed' state usually.
    }

    int nextIndex;
    if (state.isShuffleMode) {
       // Simple random shuffle for now
       nextIndex = (DateTime.now().millisecondsSinceEpoch % state.queue.length);
       if (state.queue.length > 1 && nextIndex == state.currentIndex) {
          nextIndex = (nextIndex + 1) % state.queue.length;
       }
    } else {
      nextIndex = state.currentIndex + 1;
      if (nextIndex >= state.queue.length) {
        if (state.loopMode == bloc_state.LoopMode.all) {
          nextIndex = 0; // Wrap around
        } else {
          // Stop playback at end of queue
           await _playerService.pause();
           await _playerService.seek(Duration.zero);
           return;
        }
      }
    }

    emit(state.copyWith(currentIndex: nextIndex));
    add(PlayerPlaySong(state.queue[nextIndex]));
  }

  Future<void> _onPrevious(PlayerPrevious event, Emitter<bloc_state.PlayerState> emit) async {
    if (state.queue.isEmpty) return;
    
    if (state.position.inSeconds > 3) {
      await _playerService.seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (state.isShuffleMode) {
       prevIndex = (DateTime.now().millisecondsSinceEpoch % state.queue.length);
    } else {
      prevIndex = state.currentIndex - 1;
      if (prevIndex < 0) {
        prevIndex = state.queue.length - 1;
      }
    }

    emit(state.copyWith(currentIndex: prevIndex));
    add(PlayerPlaySong(state.queue[prevIndex]));
  }

  void _onShuffle(PlayerShuffle event, Emitter<bloc_state.PlayerState> emit) {
    emit(state.copyWith(isShuffleMode: !state.isShuffleMode));
  }

  Future<void> _onRepeat(PlayerRepeat event, Emitter<bloc_state.PlayerState> emit) async {
    final nextMode = bloc_state.LoopMode.values[
      (state.loopMode.index + 1) % bloc_state.LoopMode.values.length
    ];
    emit(state.copyWith(loopMode: nextMode));
    
    // Convert util LoopMode to just_audio LoopMode
    LoopMode audioLoopMode;
    switch(nextMode) {
      case bloc_state.LoopMode.off:
         audioLoopMode = LoopMode.off;
         break;
      case bloc_state.LoopMode.all:
         audioLoopMode = LoopMode.off; // We handle 'all' manually in _onNext
         break;
      case bloc_state.LoopMode.one:
         audioLoopMode = LoopMode.one; // Native repeat one
         break;
    }
    await _playerService.setLoopMode(audioLoopMode);
  }

  Future<void> _onPlaySong(PlayerPlaySong event, Emitter<bloc_state.PlayerState> emit) async {
    emit(state.copyWith(
      status: bloc_state.PlayerStatus.loading, 
      currentSong: event.song,
      lyrics: [], // Clear old lyrics
      currentLyricLine: null,
    ));

    if (event.song.uri != null) {
      // Fetch lyrics
      final lyrics = await _lyricsRepository.getLyrics(event.song.uri!);
      
      await _playerService.setUrl(
        event.song.uri!,
        title: event.song.title,
        artist: event.song.artist,
        id: event.song.id,
        artUri: event.song.albumId != null 
          ? "content://media/external/audio/albumart/${event.song.albumId}" 
          : null,
      );
      
      // Update lyrics in state
      if (!emit.isDone) {
         emit(state.copyWith(lyrics: lyrics));
      }
      // setUrl in Service now handles play via Handler
    }
  }

  Future<void> _onPause(PlayerPause event, Emitter<bloc_state.PlayerState> emit) async {
    await _playerService.pause();
  }

  Future<void> _onResume(PlayerResume event, Emitter<bloc_state.PlayerState> emit) async {
    await _playerService.play();
  }
  
  Future<void> _onSeek(PlayerSeek event, Emitter<bloc_state.PlayerState> emit) async {
    await _playerService.seek(event.position);
  }


  Future<void> _onCheckLyrics(PlayerCheckLyrics event, Emitter<bloc_state.PlayerState> emit) async {
    if (state.currentSong?.uri == null) return;
    
    // Only fetch if we don't have lyrics (or maybe we want to retry anyway just in case file appeared)
    if (state.lyrics == null || state.lyrics!.isEmpty) {
       final lyrics = await _lyricsRepository.getLyrics(state.currentSong!.uri!);
       if (lyrics != null && lyrics.isNotEmpty) {
          emit(state.copyWith(lyrics: lyrics));
       }
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _skipNextSubscription?.cancel();
    _skipPreviousSubscription?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }
}
