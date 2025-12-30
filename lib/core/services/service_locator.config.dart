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
import '../../features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i940;
import '../../features/playlist/domain/repositories/playlist_repository.dart'
    as _i829;
import '../../features/playlist/domain/usecases/add_song_to_playlist.dart'
    as _i454;
import '../../features/playlist/domain/usecases/create_playlist.dart' as _i548;
import '../../features/playlist/domain/usecases/delete_playlist.dart' as _i709;
import '../../features/playlist/domain/usecases/get_playlists.dart' as _i224;
import '../../features/playlist/domain/usecases/remove_song_from_playlist.dart'
    as _i1018;
import '../../features/playlist/domain/usecases/rename_playlist.dart' as _i470;
import '../../features/playlist/presentation/bloc/playlist_bloc.dart' as _i397;
import '../theme/theme_cubit.dart' as _i611;
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
    gh.singleton<_i611.ThemeCubit>(() => _i611.ThemeCubit());
    gh.lazySingleton<_i859.OnAudioQuery>(() => thirdPartyModules.audioQuery);
    gh.lazySingleton<_i282.AudioPlayerService>(
        () => _i282.AudioPlayerServiceImpl(gh<_i87.AudioHandler>()));
    gh.lazySingleton<_i829.PlaylistRepository>(
        () => _i940.PlaylistRepositoryImpl());
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
    gh.lazySingleton<_i454.AddSongToPlaylist>(
        () => _i454.AddSongToPlaylist(gh<_i829.PlaylistRepository>()));
    gh.lazySingleton<_i548.CreatePlaylist>(
        () => _i548.CreatePlaylist(gh<_i829.PlaylistRepository>()));
    gh.lazySingleton<_i709.DeletePlaylist>(
        () => _i709.DeletePlaylist(gh<_i829.PlaylistRepository>()));
    gh.lazySingleton<_i224.GetPlaylists>(
        () => _i224.GetPlaylists(gh<_i829.PlaylistRepository>()));
    gh.lazySingleton<_i1018.RemoveSongFromPlaylist>(
        () => _i1018.RemoveSongFromPlaylist(gh<_i829.PlaylistRepository>()));
    gh.lazySingleton<_i470.RenamePlaylist>(
        () => _i470.RenamePlaylist(gh<_i829.PlaylistRepository>()));
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
    gh.factory<_i397.PlaylistBloc>(() => _i397.PlaylistBloc(
          getPlaylists: gh<_i224.GetPlaylists>(),
          createPlaylist: gh<_i548.CreatePlaylist>(),
          deletePlaylist: gh<_i709.DeletePlaylist>(),
          renamePlaylist: gh<_i470.RenamePlaylist>(),
          addSongToPlaylist: gh<_i454.AddSongToPlaylist>(),
          removeSongFromPlaylist: gh<_i1018.RemoveSongFromPlaylist>(),
        ));
    gh.factory<_i395.LibraryBloc>(() => _i395.LibraryBloc(
          getLocalSongs: gh<_i504.GetLocalSongs>(),
          deleteSong: gh<_i283.DeleteSong>(),
        ));
    return this;
  }
}

class _$ThirdPartyModules extends _i1006.ThirdPartyModules {}
