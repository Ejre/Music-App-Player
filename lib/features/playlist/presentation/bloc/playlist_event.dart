import 'package:equatable/equatable.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../data/models/playlist_model.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylists extends PlaylistEvent {}

class CreatePlaylistEvent extends PlaylistEvent {
  final String name;

  const CreatePlaylistEvent(this.name);

  @override
  List<Object> get props => [name];
}

class DeletePlaylistEvent extends PlaylistEvent {
  final String playlistId;

  const DeletePlaylistEvent(this.playlistId);

  @override
  List<Object> get props => [playlistId];
}

class RenamePlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final String newName;

  const RenamePlaylistEvent(this.playlistId, this.newName);

  @override
  List<Object> get props => [playlistId, newName];
}

class AddSongToPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final SongModel song;

  const AddSongToPlaylistEvent(this.playlistId, this.song);

  @override
  List<Object> get props => [playlistId, song];
}

class RemoveSongFromPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final int songId;

  const RemoveSongFromPlaylistEvent(this.playlistId, this.songId);

  @override
  List<Object> get props => [playlistId, songId];
}
