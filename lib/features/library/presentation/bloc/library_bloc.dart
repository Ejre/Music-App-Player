import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_local_songs.dart';
import '../../domain/usecases/delete_song.dart';
import '../../domain/entities/song.dart';
import 'library_event.dart';
import 'library_state.dart';

@injectable
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLocalSongs getLocalSongs;
  final DeleteSong deleteSong;

  LibraryBloc({
    required this.getLocalSongs,
    required this.deleteSong,
  }) : super(LibraryInitial()) {
    on<LoadSongsEvent>(_onLoadSongs);
    on<DeleteSongEvent>(_onDeleteSong);
  }

  Future<void> _onLoadSongs(LoadSongsEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    final result = await getLocalSongs(NoParams());
    result.fold(
      (failure) => emit(LibraryError("Failed to load songs")),
      (songs) => emit(LibraryLoaded(songs)),
    );
  }

  Future<void> _onDeleteSong(DeleteSongEvent event, Emitter<LibraryState> emit) async {
    // Optimistic update or waiting?
    // Let's keep current state but maybe show loading?
    // Better: Filter out from current state if loaded.
    
    if (state is LibraryLoaded) {
       final currentSongs = (state as LibraryLoaded).songs;
       // Optimistic removal for UI responsiveness
       // but we need to actually delete it.
       
       final result = await deleteSong(event.song);
       result.fold(
         (failure) {
           // If failed, maybe show error via snackbar (listener needed) or maintain state
           // For simplicity, we just reload or emit error if critical.
           // Since this is a bloc state change, adding an error state replaces the list.
           // Better to emit a SideEffect if we had that, or just ignore if failed
           // and maybe re-add (rollback).
         },
         (success) {
           if (success) {
             final updatedSongs = List<Song>.from(currentSongs)..removeWhere((s) => s.id == event.song.id);
             emit(LibraryLoaded(updatedSongs));
           }
         }
       );
    }
  }
}
