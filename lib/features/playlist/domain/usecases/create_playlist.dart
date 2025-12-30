import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class CreatePlaylist implements UseCase<void, CreatePlaylistParams> {
  final PlaylistRepository repository;

  CreatePlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(CreatePlaylistParams params) async {
    return await repository.createPlaylist(params.name);
  }
}

class CreatePlaylistParams extends Equatable {
  final String name;

  const CreatePlaylistParams(this.name);

  @override
  List<Object> get props => [name];
}
