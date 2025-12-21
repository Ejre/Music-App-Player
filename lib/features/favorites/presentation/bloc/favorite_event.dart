import 'package:equatable/equatable.dart';
import '../../../library/domain/entities/song.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final Song song;
  const ToggleFavorite(this.song);

  @override
  List<Object> get props => [song];
}
