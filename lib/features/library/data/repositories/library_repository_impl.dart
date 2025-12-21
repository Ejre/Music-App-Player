import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/local_song_data_source.dart';

@LazySingleton(as: LibraryRepository)
class LibraryRepositoryImpl implements LibraryRepository {
  final LocalSongDataSource dataSource;

  LibraryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Song>>> getLocalSongs() async {
    try {
      final songModels = await dataSource.getSongs();
      return Right(songModels);
    } catch (e) {
      return Left(AudioScanFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSong(Song song) async {
    try {
      // We expect song.uri to be the file path in this context (local file)
      // If it is a content URI, we might need to rely on different logic.
      // But usually 'data' column from MediaStore is the path.
      if (song.uri != null) {
         final result = await dataSource.deleteSong(song.uri!);
         if (result) {
            return const Right(true);
         } else {
            return Left(AudioScanFailure()); // Generic failure for now
         }
      }
      return Left(AudioScanFailure());
    } catch (e) {
      return Left(AudioScanFailure());
    }
  }
}
