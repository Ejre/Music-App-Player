import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class AddSongToPlaylist implements UseCase<void, AddSongToPlaylistParams> {
  final PlaylistRepository repository;

  AddSongToPlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(AddSongToPlaylistParams params) async {
    return await repository.addSongToPlaylist(params.playlistId, params.songId);
  }
}

class AddSongToPlaylistParams extends Equatable {
  final String playlistId;
  final int songId;

  const AddSongToPlaylistParams(this.playlistId, this.songId);

  @override
  List<Object> get props => [playlistId, songId];
}
