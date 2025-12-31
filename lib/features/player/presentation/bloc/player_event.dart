import 'package:equatable/equatable.dart';
import '../../../../features/library/domain/entities/song.dart';
import 'player_state.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerPlaySong extends PlayerEvent {
  final Song song;
  const PlayerPlaySong(this.song);

  @override
  List<Object?> get props => [song];
}

class PlayerLoadLyrics extends PlayerEvent {
  final Song song;
  const PlayerLoadLyrics(this.song);
  @override
  List<Object?> get props => [song];
}

class PlayerPause extends PlayerEvent {}
class PlayerResume extends PlayerEvent {}
class PlayerSeek extends PlayerEvent {
  final Duration position;
  const PlayerSeek(this.position);
}

class PlayerSetQueue extends PlayerEvent {
  final List<Song> queue;
  final int initialIndex;

  const PlayerSetQueue(this.queue, {this.initialIndex = 0});

  @override
  List<Object?> get props => [queue, initialIndex];
}

class PlayerNext extends PlayerEvent {}

class PlayerPrevious extends PlayerEvent {}

class PlayerShuffle extends PlayerEvent {}

class PlayerRepeat extends PlayerEvent {}

class PlayerStateChanged extends PlayerEvent {
  final PlayerStatus status; // Changed from bool to PlayerStatus
  const PlayerStateChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class PlayerDurationChanged extends PlayerEvent {
  final Duration duration;
  const PlayerDurationChanged(this.duration);
  @override
  List<Object?> get props => [duration];
}

class PlayerPositionChanged extends PlayerEvent {
  final Duration position;
  const PlayerPositionChanged(this.position);
  @override
  List<Object?> get props => [position];
}

class PlayerCheckLyrics extends PlayerEvent {}

class SetSleepTimer extends PlayerEvent {
  final Duration duration;
  const SetSleepTimer(this.duration);
  @override
  List<Object?> get props => [duration];
}

class CancelSleepTimer extends PlayerEvent {}
