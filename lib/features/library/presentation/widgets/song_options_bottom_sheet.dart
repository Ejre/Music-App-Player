import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/song.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark grey background like reference
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Song Info + Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Artwork (Tiny) or just Text? Reference shows text mostly.
                // Let's add tiny artwork for context.
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
                  icon: const Icon(Icons.thumb_up_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          
          // 2. Big Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBigActionButton(context, Icons.playlist_play, "Play next"),
                _buildBigActionButton(context, Icons.playlist_add, "Save to playlist"),
                _buildBigActionButton(context, Icons.share_outlined, "Share"),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // 3. List Options
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildListOption(context, Icons.queue_music, "Add to queue"),
                // _buildListOption(context, Icons.library_add_outlined, "Save to library"), // Irrelevant for local
                // _buildListOption(context, Icons.download_outlined, "Download"), // Irrelevant
                _buildListOption(context, Icons.album_outlined, "Go to album"),
                _buildListOption(context, Icons.person_outline, "Go to artist"),
                _buildListOption(context, Icons.info_outline, "Song Info"), // Changed from Credits to Info (size, format etc)
                // _buildListOption(context, Icons.push_pin_outlined, "Pin to Speed dial"), // Irrelevant
                // _buildListOption(context, Icons.block_outlined, "Not interested"), // Irrelevant
                
                // Delete Option (Real functionality)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Delete from device", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    onDelete(); // Trigger delete confirmation
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigActionButton(BuildContext context, IconData icon, String label) {
    return Container(
      width: 100, // Fixed width for uniformity
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Slightly lighter grey for buttons
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
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
    );
  }

  Widget _buildListOption(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}
