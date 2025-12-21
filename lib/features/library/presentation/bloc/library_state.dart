import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';

abstract class LibraryState extends Equatable {
  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Song> songs;
  
  LibraryLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class LibraryError extends LibraryState {
  final String message;

  LibraryError(this.message);

  @override
  List<Object> get props => [message];
}
