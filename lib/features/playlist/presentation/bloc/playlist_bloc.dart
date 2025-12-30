import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_song_to_playlist.dart';
import '../../domain/usecases/create_playlist.dart';
import '../../domain/usecases/delete_playlist.dart';
import '../../domain/usecases/get_playlists.dart';
import '../../domain/usecases/remove_song_from_playlist.dart';
import '../../domain/usecases/rename_playlist.dart';
import 'playlist_event.dart';
import 'playlist_state.dart';

@injectable
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetPlaylists getPlaylists;
  final CreatePlaylist createPlaylist;
  final DeletePlaylist deletePlaylist;
  final RenamePlaylist renamePlaylist;
  final AddSongToPlaylist addSongToPlaylist;
  final RemoveSongFromPlaylist removeSongFromPlaylist;

  PlaylistBloc({
    required this.getPlaylists,
    required this.createPlaylist,
    required this.deletePlaylist,
    required this.renamePlaylist,
    required this.addSongToPlaylist,
    required this.removeSongFromPlaylist,
  }) : super(PlaylistInitial()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<DeletePlaylistEvent>(_onDeletePlaylist);
    on<RenamePlaylistEvent>(_onRenamePlaylist);
    on<AddSongToPlaylistEvent>(_onAddSongToPlaylist);
    on<RemoveSongFromPlaylistEvent>(_onRemoveSongFromPlaylist);
  }

  Future<void> _onLoadPlaylists(LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    final result = await getPlaylists(NoParams());
    result.fold(
      (failure) => emit(const PlaylistError("Failed to load playlists")),
      (playlists) => emit(PlaylistLoaded(playlists)),
    );
  }

  Future<void> _onCreatePlaylist(CreatePlaylistEvent event, Emitter<PlaylistState> emit) async {
    await createPlaylist(CreatePlaylistParams(event.name));
    add(LoadPlaylists());
  }

  Future<void> _onDeletePlaylist(DeletePlaylistEvent event, Emitter<PlaylistState> emit) async {
    await deletePlaylist(DeletePlaylistParams(event.playlistId));
    add(LoadPlaylists());
  }

  Future<void> _onRenamePlaylist(RenamePlaylistEvent event, Emitter<PlaylistState> emit) async {
    await renamePlaylist(RenamePlaylistParams(event.playlistId, event.newName));
    add(LoadPlaylists());
  }

  Future<void> _onAddSongToPlaylist(AddSongToPlaylistEvent event, Emitter<PlaylistState> emit) async {
    await addSongToPlaylist(AddSongToPlaylistParams(event.playlistId, event.song.id));
    // Don't reload everything if we can avoid it, but for now it's safer to ensure consistency
    add(LoadPlaylists()); 
    // Ideally we might want to just emit a "SongAdded" effect, but State flow is simpler here
  }

  Future<void> _onRemoveSongFromPlaylist(RemoveSongFromPlaylistEvent event, Emitter<PlaylistState> emit) async {
    await removeSongFromPlaylist(RemoveSongFromPlaylistParams(event.playlistId, event.songId));
    add(LoadPlaylists());
  }
}
