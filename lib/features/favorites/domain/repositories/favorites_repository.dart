import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<int>>> getFavoriteIds();
  Future<Either<Failure, void>> addFavorite(int songId);
  Future<Either<Failure, void>> removeFavorite(int songId);
  Future<bool> isFavorite(int songId);
}
