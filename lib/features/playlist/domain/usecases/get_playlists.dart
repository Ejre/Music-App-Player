import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/playlist_model.dart';
import '../repositories/playlist_repository.dart';

@lazySingleton
class GetPlaylists implements UseCase<List<PlaylistModel>, NoParams> {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  @override
  Future<Either<Failure, List<PlaylistModel>>> call(NoParams params) async {
    return await repository.getPlaylists();
  }
}
