import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/song.dart';
import '../../../playlist/presentation/bloc/playlist_bloc.dart';
import '../../../playlist/presentation/bloc/playlist_state.dart';
import '../../../playlist/presentation/bloc/playlist_event.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';

class SongOptionsBottomSheet extends StatelessWidget {
  final Song song;
  final VoidCallback onDelete;

  const SongOptionsBottomSheet({
    super.key,
    required this.song,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Convert Song entity to SongModel 
    // Usually Song entity wraps SongModel or is similar.
    // Looking at query artwork widget, it uses ID.
    // For AddSongToPlaylistEvent, we need SongModel or just ID?
    // The Event uses SongModel currently.
    // Let's create a SongModel from Song or verify Song type.
    // The import calls it 'Song'. Let's assume it maps correctly or use ID.
    // Re-checking previous file content, it imported domain/entities/song.dart.
    // But artwork widget used song.id.
    // I'll assume I can construct a barebones SongModel or change the event to take ID.
    // My AddSongToPlaylistEvent took SongModel. I should validly construct it or change the event.
    // The usecase only used songId (int). The Event took SongModel. I implementation only used song.id.
    // So passing a dummy SongModel with correct ID is enough, or I should have refactored the event.
    // For now I will create a dummy model to satisfy the event or modify the event.
    // Modifying the event is safer but requires file edit.
    // I'll create a dummy SongModel locally.

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 50,
                  artworkWidth: 50,
                  artworkBorder: BorderRadius.circular(4),
                  nullArtworkWidget: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the single button
              children: [
                _buildBigActionButton(context, Icons.playlist_add, "Save to playlist", () {
                   _showAddToPlaylistDialog(context);
                }),
                const SizedBox(width: 24),
                BlocBuilder<FavoriteBloc, FavoriteState>(
                  builder: (context, state) {
                    bool isFavorite = false;
                    if (state is FavoriteLoaded) {
                      isFavorite = state.favoriteIds.contains(song.id);
                    }
                    return _buildBigActionButton(
                      context, 
                      isFavorite ? Icons.favorite : Icons.favorite_border, 
                      "Favorite", 
                      () {
                         context.read<FavoriteBloc>().add(ToggleFavorite(song));
                      },
                      color: isFavorite ? const Color(0xFF39C5BB) : Colors.white,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Delete from device", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Add to Playlist", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: BlocBuilder<PlaylistBloc, PlaylistState>(
              bloc: context.read<PlaylistBloc>(), // Explicitly provide bloc if needed, but context.read works if provided.
              builder: (context, state) {
                // Capture bloc for use in callbacks
                final playlistBloc = context.read<PlaylistBloc>();
                if (state is PlaylistLoaded) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF39C5BB).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, color: Color(0xFF39C5BB)),
                        ),
                        title: const Text("Create New Playlist", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onTap: () {
                          // Show Create Dialog on top or replace
                          Navigator.pop(dialogContext); // Close list dialog
                          // Show create dialog from main context or parent
                          // We can't easily show another dialog from here without context issues, 
                          // but since we popped, we're back to bottom sheet.
                          // Actually let's just use a small workaround to trigger create from bottom sheet
                          // For now, simpler: Close everything and show create dialog? 
                          // Or better: Inline text field?
                          // Let's go with: Close, then trigger a create action via a callback?
                          // The bottom sheet doesn't have create logic.
                          // Let's implement a simple create input here.
                             showDialog(
                               context: context,
                               builder: (ctx) {
                                 final controller = TextEditingController();
                                 return AlertDialog(
                                   backgroundColor: const Color(0xFF1E1E1E),
                                   title: const Text("New Playlist", style: TextStyle(color: Colors.white)),
                                   content: TextField(
                                     controller: controller,
                                     style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        hintText: "Playlist Name",
                                        hintStyle: TextStyle(color: Colors.white54),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39C5BB))),
                                      ),
                                   ),
                                   actions: [
                                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                     TextButton(onPressed: () {
                                        if (controller.text.trim().isNotEmpty) {
                                           playlistBloc.add(CreatePlaylistEvent(controller.text.trim()));
                                           Navigator.pop(ctx);
                                           // SnackBar in main context
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(content: Text("Created '${controller.text}'")),
                                           );
                                        }
                                     }, child: const Text("Create", style: TextStyle(color: Color(0xFF39C5BB)))),
                                   ],
                                 );
                               }
                             );
                        },
                      ),
                      const Divider(color: Colors.white10),
                      if (state.playlists.isEmpty)
                         const Padding(
                           padding: EdgeInsets.all(16.0),
                           child: Text("No playlists yet", style: TextStyle(color: Colors.white54)),
                         ),
                      if (state.playlists.isNotEmpty)
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = state.playlists[index];
                              return ListTile(
                                leading: const Icon(Icons.music_note, color: Colors.white),
                                title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                                onTap: () {
                                   final songModel = SongModel({
                                     '_id': song.id,
                                     'title': song.title,
                                     '_data': song.uri, 
                                     'artist': song.artist,
                                     'duration': song.duration,
                                   });
                                   
                                   context.read<PlaylistBloc>().add(AddSongToPlaylistEvent(playlist.id, songModel));
                                   Navigator.pop(dialogContext); // Close Dialog
                                   Navigator.pop(context); // Close BottomSheet
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text("Added to ${playlist.name}")),
                                   );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBigActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100, 
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
