import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';

abstract class LibraryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadSongsEvent extends LibraryEvent {}

class DeleteSongEvent extends LibraryEvent {
  final Song song;
  DeleteSongEvent(this.song);
}
