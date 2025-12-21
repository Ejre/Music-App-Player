// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:audio_service/audio_service.dart' as _i87;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:on_audio_query/on_audio_query.dart' as _i859;

import '../../features/favorites/data/repositories/favorites_repository_impl.dart'
    as _i144;
import '../../features/favorites/domain/repositories/favorites_repository.dart'
    as _i212;
import '../../features/favorites/domain/usecases/add_favorite.dart' as _i705;
import '../../features/favorites/domain/usecases/get_favorite_ids.dart'
    as _i1017;
import '../../features/favorites/domain/usecases/remove_favorite.dart' as _i828;
import '../../features/favorites/presentation/bloc/favorite_bloc.dart' as _i866;
import '../../features/library/data/datasources/local_song_data_source.dart'
    as _i448;
import '../../features/library/data/repositories/library_repository_impl.dart'
    as _i912;
import '../../features/library/domain/repositories/library_repository.dart'
    as _i810;
import '../../features/library/domain/usecases/delete_song.dart' as _i283;
import '../../features/library/domain/usecases/get_local_songs.dart' as _i504;
import '../../features/library/presentation/bloc/library_bloc.dart' as _i395;
import '../../features/player/data/repositories/lyrics_repository.dart'
    as _i1028;
import '../../features/player/data/services/audio_player_service.dart' as _i282;
import '../../features/player/presentation/bloc/player_bloc.dart' as _i333;
import 'third_party_modules.dart' as _i1006;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final thirdPartyModules = _$ThirdPartyModules();
    await gh.factoryAsync<_i87.AudioHandler>(
      () => thirdPartyModules.audioHandler,
      preResolve: true,
    );
    gh.factory<_i1028.LyricsRepository>(() => _i1028.LyricsRepository());
    gh.lazySingleton<_i859.OnAudioQuery>(() => thirdPartyModules.audioQuery);
    gh.lazySingleton<_i282.AudioPlayerService>(
        () => _i282.AudioPlayerServiceImpl(gh<_i87.AudioHandler>()));
    gh.lazySingleton<_i212.FavoritesRepository>(
        () => _i144.FavoritesRepositoryImpl());
    gh.lazySingleton<_i705.AddFavorite>(
        () => _i705.AddFavorite(gh<_i212.FavoritesRepository>()));
    gh.lazySingleton<_i1017.GetFavoriteIds>(
        () => _i1017.GetFavoriteIds(gh<_i212.FavoritesRepository>()));
    gh.lazySingleton<_i828.RemoveFavorite>(
        () => _i828.RemoveFavorite(gh<_i212.FavoritesRepository>()));
    gh.factory<_i333.PlayerBloc>(() => _i333.PlayerBloc(
          gh<_i282.AudioPlayerService>(),
          gh<_i1028.LyricsRepository>(),
        ));
    gh.lazySingleton<_i448.LocalSongDataSource>(
        () => _i448.LocalSongDataSourceImpl(gh<_i859.OnAudioQuery>()));
    gh.factory<_i866.FavoriteBloc>(() => _i866.FavoriteBloc(
          gh<_i1017.GetFavoriteIds>(),
          gh<_i705.AddFavorite>(),
          gh<_i828.RemoveFavorite>(),
        ));
    gh.lazySingleton<_i810.LibraryRepository>(
        () => _i912.LibraryRepositoryImpl(gh<_i448.LocalSongDataSource>()));
    gh.lazySingleton<_i283.DeleteSong>(
        () => _i283.DeleteSong(gh<_i810.LibraryRepository>()));
    gh.lazySingleton<_i504.GetLocalSongs>(
        () => _i504.GetLocalSongs(gh<_i810.LibraryRepository>()));
    gh.factory<_i395.LibraryBloc>(() => _i395.LibraryBloc(
          getLocalSongs: gh<_i504.GetLocalSongs>(),
          deleteSong: gh<_i283.DeleteSong>(),
        ));
    return this;
  }
}

class _$ThirdPartyModules extends _i1006.ThirdPartyModules {}
