import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorite_ids.dart';
import '../../domain/usecases/remove_favorite.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

@injectable
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetFavoriteIds getFavoriteIds;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;

  FavoriteBloc(
    this.getFavoriteIds,
    this.addFavorite,
    this.removeFavorite,
  ) : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    final result = await getFavoriteIds(NoParams());
    result.fold(
      (failure) => emit(const FavoriteError("Failed to load favorites")),
      (ids) => emit(FavoriteLoaded(ids.toSet())),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      final isFav = currentState.favoriteIds.contains(event.song.id);
      final Set<int> updatedIds = Set.from(currentState.favoriteIds);
      
      // Optimistic update
      if (isFav) {
        updatedIds.remove(event.song.id);
      } else {
        updatedIds.add(event.song.id);
      }
      emit(FavoriteLoaded(updatedIds));

      final result = isFav 
          ? await removeFavorite(event.song.id) 
          : await addFavorite(event.song.id);
      
      result.fold(
        (failure) {
          // Revert on failure
          if (isFav) {
            updatedIds.add(event.song.id);
          } else {
            updatedIds.remove(event.song.id);
          }
          emit(FavoriteLoaded(updatedIds));
          // Optionally emit error side-effect
        },
        (_) {},
      );
    }
  }
}
