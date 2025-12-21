import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

@LazySingleton()
class AddFavorite implements UseCase<void, int> {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.addFavorite(params);
  }
}
