import 'package:equatable/equatable.dart';
import '../../domain/entities/lyric_line.dart';
import '../../../../features/library/domain/entities/song.dart';

enum PlayerStatus { initial, playing, paused, loading }

enum LoopMode { off, all, one }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isShuffleMode;
  final LoopMode loopMode;
  final Duration position;
  final Duration duration;
  final List<LyricLine>? lyrics;
  final LyricLine? currentLyricLine;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentSong,
    this.queue = const [],
    this.currentIndex = -1,
    this.isShuffleMode = false,
    this.loopMode = LoopMode.off,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.lyrics,
    this.currentLyricLine,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isShuffleMode,
    LoopMode? loopMode,
    Duration? position,
    Duration? duration,
    List<LyricLine>? lyrics,
    LyricLine? currentLyricLine,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffleMode: isShuffleMode ?? this.isShuffleMode,
      loopMode: loopMode ?? this.loopMode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
      currentLyricLine: currentLyricLine ?? this.currentLyricLine,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentSong,
        queue,
        currentIndex,
        isShuffleMode,
        loopMode,
        position,
        duration,
        lyrics,
        currentLyricLine,
      ];
}
