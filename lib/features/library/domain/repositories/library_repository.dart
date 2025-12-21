import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/song.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<Song>>> getLocalSongs();
  Future<Either<Failure, bool>> deleteSong(Song song);
}
