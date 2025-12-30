import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, List<PlaylistModel>>> getPlaylists();
  Future<Either<Failure, void>> createPlaylist(String name);
  Future<Either<Failure, void>> deletePlaylist(String id);
  Future<Either<Failure, void>> renamePlaylist(String id, String newName);
  Future<Either<Failure, void>> addSongToPlaylist(String playlistId, int songId);
  Future<Either<Failure, void>> removeSongFromPlaylist(String playlistId, int songId);
}
