import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

@LazySingleton()
class GetFavoriteIds implements UseCase<List<int>, NoParams> {
  final FavoritesRepository repository;

  GetFavoriteIds(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(NoParams params) async {
    return await repository.getFavoriteIds();
  }
}
