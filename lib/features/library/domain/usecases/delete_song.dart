import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/song.dart';
import '../repositories/library_repository.dart';

@lazySingleton
class DeleteSong implements UseCase<bool, Song> {
  final LibraryRepository repository;

  DeleteSong(this.repository);

  @override
  Future<Either<Failure, bool>> call(Song params) async {
    return await repository.deleteSong(params);
  }
}
