import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class RenamePlaylist implements UseCase<void, RenamePlaylistParams> {
  final PlaylistRepository repository;

  RenamePlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(RenamePlaylistParams params) async {
    return await repository.renamePlaylist(params.id, params.newName);
  }
}

class RenamePlaylistParams extends Equatable {
  final String id;
  final String newName;

  const RenamePlaylistParams(this.id, this.newName);

  @override
  List<Object> get props => [id, newName];
}
