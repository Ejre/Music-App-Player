import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../library/domain/entities/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isPlaying ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
            border: isPlaying ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1) : null,
          ),
          child: Row(
            children: [
              // Artwork with shadow and rounded corners
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkHeight: 56,
                        artworkWidth: 56,
                        size: 200, // Optimized Size
                        quality: 100,
                        format: ArtworkFormat.JPEG,
                        nullArtworkWidget: Container(
                          width: 56,
                          height: 56,
                          color: const Color(0xFF2A2A2A),
                          child: Icon(Icons.music_note, color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      // Playing Indicator Overlay
                      if (isPlaying)
                        Container(
                          width: 56,
                          height: 56,
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.graphic_eq, // Simple equalizer icon
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPlaying ? theme.colorScheme.primary : Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist == "<unknown>" ? "Unknown Artist" : song.artist,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action / Visuals (e.g. duration or menu)
              if (!isPlaying)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.3), size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              else 
                 Icon(Icons.volume_up_rounded, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
