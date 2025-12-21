import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_state.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_state.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/bloc/player_event.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, libraryState) {
          if (libraryState is LibraryLoaded) {
            return BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favState) {
                if (favState is FavoriteLoaded) {
                  final favoriteSongs = libraryState.songs
                      .where((song) => favState.favoriteIds.contains(song.id))
                      .toList();

                  if (favoriteSongs.isEmpty) {
                     return Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.favorite_border, size: 80, color: Colors.white24),
                           SizedBox(height: 16),
                           Text("No favorites yet", style: TextStyle(color: Colors.white54)),
                         ],
                       ),
                     );
                  }

                  return ListView.builder(
                    itemCount: favoriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = favoriteSongs[index];
                      return ListTile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(Icons.music_note),
                        ),
                        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                           context.read<PlayerBloc>().add(PlayerSetQueue(favoriteSongs, initialIndex: index));
                        },
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
