import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/playlistprovider.dart';
import '../pages/songpage.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        // If no song is selected yet, don't show the mini player
        if (value.currentSongIndex == null || value.playlist.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentSong = value.playlist[value.currentSongIndex!];

        return GestureDetector(
          onTap: () {
            // Navigate to the full song page when tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Songpage()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Using a nice Glassmorphism style color
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Album Art - UPDATED TO NETWORK
                Hero(
                  tag:
                      'album_art_${currentSong.songName}', // Smooth transition to SongPage
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      currentSong.albumArtPath,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.music_note),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Song Title & Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentSong.songName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.artistName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Controls
                Row(
                  children: [
                    // Play/Pause Icon (Visual only here, logic stays in SongPage/Provider)
                    const Icon(Icons.pause_circle_filled, size: 35),

                    const SizedBox(width: 10),

                    // Next Button (Triggers your Euclidean Distance logic)
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        // This triggers the mathematical jump to the next best song
                        value.playNextByMood();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
