import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/favorites_repository.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  static const String boxName = 'favorites';

  Future<Box<int>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<int>(boxName);
    }
    return await Hive.openBox<int>(boxName);
  }

  @override
  Future<Either<Failure, List<int>>> getFavoriteIds() async {
    try {
      final box = await _openBox();
      final ids = box.values.toList();
      return Right(ids);
    } catch (e) {
      return Left(CacheFailure()); // You might need to define CacheFailure in core
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(int songId) async {
    try {
      final box = await _openBox();
      if (!box.values.contains(songId)) {
        await box.add(songId);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int songId) async {
    try {
      final box = await _openBox();
      // Hive list behavior is tricky, we might want to store as map ID -> ID or just delete by value
      // simpler: delete manual filter? Or store as Map<int, int> where key is ID.
      // Let's iterate and delete key.
      final keyToDelete = box.keys.firstWhere((k) => box.get(k) == songId, orElse: () => null);
      if (keyToDelete != null) {
        await box.delete(keyToDelete);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<bool> isFavorite(int songId) async {
    final box = await _openBox();
    return box.values.contains(songId);
  }
}
