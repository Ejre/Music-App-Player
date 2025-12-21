import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_state.dart';
import '../../../../features/player/presentation/bloc/player_bloc.dart';
import '../../../../features/player/presentation/bloc/player_event.dart';

class SongSearchDelegate extends SearchDelegate {
  final LibraryBloc libraryBloc;

  SongSearchDelegate(this.libraryBloc);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final state = libraryBloc.state;
    if (state is LibraryLoaded) {
      final songs = state.songs;
      final filteredSongs = songs.where((song) {
        final q = query.toLowerCase();
        return song.title.toLowerCase().contains(q) || 
               song.artist.toLowerCase().contains(q);
      }).toList();

      if (filteredSongs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                "No songs found for '$query'",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredSongs.length,
        itemBuilder: (context, index) {
          final song = filteredSongs[index];
          return ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkHeight: 50,
              artworkWidth: 50,
              nullArtworkWidget: Container(
                width: 50,
                height: 50,
                color: Colors.white10,
                child: const Icon(Icons.music_note),
              ),
            ),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              // Close search and play
              close(context, null);
              context.read<PlayerBloc>().add(PlayerSetQueue(filteredSongs, initialIndex: index));
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
