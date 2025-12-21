import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

@LazySingleton()
class RemoveFavorite implements UseCase<void, int> {
  final FavoritesRepository repository;

  RemoveFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.removeFavorite(params);
  }
}
