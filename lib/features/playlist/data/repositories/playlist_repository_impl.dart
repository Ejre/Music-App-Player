import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist_model.dart';

@LazySingleton(as: PlaylistRepository)
class PlaylistRepositoryImpl implements PlaylistRepository {
  static const String boxName = 'playlists';

  Future<Box<PlaylistModel>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<PlaylistModel>(boxName);
    }
    return await Hive.openBox<PlaylistModel>(boxName);
  }

  @override
  Future<Either<Failure, List<PlaylistModel>>> getPlaylists() async {
    try {
      final box = await _openBox();
      return Right(box.values.toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createPlaylist(String name) async {
    try {
      final box = await _openBox();
      final newPlaylist = PlaylistModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
      );
      await box.put(newPlaylist.id, newPlaylist);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> renamePlaylist(String id, String newName) async {
    try {
      final box = await _openBox();
      final playlist = box.get(id);
      if (playlist != null) {
        playlist.name = newName;
        await playlist.save(); // HiveObject extends Save
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addSongToPlaylist(String playlistId, int songId) async {
    try {
      final box = await _openBox();
      final playlist = box.get(playlistId);
      if (playlist != null) {
        if (!playlist.songIds.contains(songId)) {
          playlist.songIds.add(songId);
          await playlist.save();
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeSongFromPlaylist(String playlistId, int songId) async {
    try {
      final box = await _openBox();
      final playlist = box.get(playlistId);
      if (playlist != null) {
        playlist.songIds.remove(songId);
        await playlist.save();
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
