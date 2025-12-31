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
  StreamSubscription? _mediaItemSubscription;

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
    on<PlayerLoadLyrics>(_onLoadLyrics);
    on<PlayerCheckLyrics>(_onCheckLyrics);

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
       // Since moving logic to handler, this stream might be triggered BY the handler
       // when it skips. We don't need to do logic here, just maybe update UI?
       // Actually, we should listen to MEDIA ITEM change to update UI.
       // Skip stream is mostly for UI buttons if we were using 'text' notifications
       // but here AudioHandler triggers it? 
       // JustAudioBackground handles notification buttons automatically calling skipToNext.
    });

    _skipPreviousSubscription = _playerService.skipToPreviousStream.listen((_) {
    });

    _mediaItemSubscription = _playerService.mediaItemStream.listen((mediaItem) {
        if (mediaItem == null) return;
        
        // Find song in queue that matches mediaItem
        // Or reconstruct song?
        // Ideally we find it in our queue to keep object reference consistency if possible
        try {
           final matchSong = state.queue.firstWhere((s) => s.id.toString() == mediaItem.id);
           final index = state.queue.indexOf(matchSong);
           
           if (matchSong != state.currentSong) {
              add(PlayerPlaySong(matchSong)); // Re-use event to update state
              // But we need to make sure _onPlaySong doesn't restart playback if it's already playing!
              // See _onPlaySong changes.
              
              // Actually, better: emit state directly or have a valid event "PlayerSongChanged"
              // Reuse _onPlaySong but remove the 'setUrl' part inside it?
           }
           
           // Update index
           if (index != -1 && index != state.currentIndex) {
              emit(state.copyWith(currentIndex: index));
           }
        } catch (e) {
           // Not found in queue?
        }
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
    emit(state.copyWith(queue: event.queue));
    await _playerService.setQueue(event.queue, event.initialIndex);
  }

  Future<void> _onNext(PlayerNext event, Emitter<bloc_state.PlayerState> emit) async {
    await _playerService.skipToNext();
  }

  Future<void> _onPrevious(PlayerPrevious event, Emitter<bloc_state.PlayerState> emit) async {
     await _playerService.skipToPrevious();
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
         audioLoopMode = LoopMode.off; 
         break;
      case bloc_state.LoopMode.one:
         audioLoopMode = LoopMode.one; 
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
    
    add(PlayerLoadLyrics(event.song));

    // If playSong is called for a single song, we check if it matches one in the queue
    int index = -1;
    if (state.queue.isNotEmpty) {
      index = state.queue.indexWhere((s) => s.id == event.song.id);
    }

    if (index != -1) {
       // Song found in queue, skip to it
       // But only skipping if we are not already playing it?
       // Just audio handles seeking to same item usually restarts it or does nothing.
       // We should force play if paused?
       await _playerService.skipToQueueItem(index);
       await _playerService.play();
    } else {
       // Song not in queue, create a queue of 1 and play
       await _playerService.setQueue([event.song], 0);
    }
  }

  Future<void> _onLoadLyrics(PlayerLoadLyrics event, Emitter<bloc_state.PlayerState> emit) async {
      if (event.song.uri == null) return;
      try {
        final lyrics = await _lyricsRepository.getLyrics(event.song.uri!);
        // Only update if the song hasn't changed in the meantime
        if (state.currentSong?.id == event.song.id) {
           emit(state.copyWith(lyrics: lyrics ?? []));
        }
      } catch (e) {
         // Ignore
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
    if (state.currentSong == null) return;
    
    if (state.lyrics == null || state.lyrics!.isEmpty) {
       add(PlayerLoadLyrics(state.currentSong!));
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _skipNextSubscription?.cancel();
    _skipPreviousSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }
}
