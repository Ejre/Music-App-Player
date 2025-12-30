import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class RemoveSongFromPlaylist implements UseCase<void, RemoveSongFromPlaylistParams> {
  final PlaylistRepository repository;

  RemoveSongFromPlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveSongFromPlaylistParams params) async {
    return await repository.removeSongFromPlaylist(params.playlistId, params.songId);
  }
}

class RemoveSongFromPlaylistParams extends Equatable {
  final String playlistId;
  final int songId;

  const RemoveSongFromPlaylistParams(this.playlistId, this.songId);

  @override
  List<Object> get props => [playlistId, songId];
}
