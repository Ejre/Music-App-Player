import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class DeletePlaylist implements UseCase<void, DeletePlaylistParams> {
  final PlaylistRepository repository;

  DeletePlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePlaylistParams params) async {
    return await repository.deletePlaylist(params.id);
  }
}

class DeletePlaylistParams extends Equatable {
  final String id;

  const DeletePlaylistParams(this.id);

  @override
  List<Object> get props => [id];
}
