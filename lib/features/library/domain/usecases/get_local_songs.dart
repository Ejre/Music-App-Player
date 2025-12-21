import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/song.dart';
import '../repositories/library_repository.dart';

@lazySingleton
class GetLocalSongs implements UseCase<List<Song>, NoParams> {
  final LibraryRepository repository;

  GetLocalSongs(this.repository);

  @override
  Future<Either<Failure, List<Song>>> call(NoParams params) async {
    return await repository.getLocalSongs();
  }
}
