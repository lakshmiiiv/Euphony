import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/neubox.dart';
import '../model/playlistprovider.dart';

class Songpage extends StatefulWidget {
  const Songpage({super.key});

  @override
  State<Songpage> createState() => _SongpageState();
}

class _SongpageState extends State<Songpage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to player state (playing/paused)
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state == PlayerState.playing);
      }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => position = newPosition);
    });

    // Start playing as soon as we land on the page
    _playCurrentSong();
  }

  // UPDATED: Added better error handling for the stream
  void _playCurrentSong() async {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);
    final song = provider.playlist[provider.currentSongIndex!];

    if (song.audioPath.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(song.audioPath));
      } catch (e) {
        print("AUDIO ERROR: $e");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final currentSong = value.playlist[value.currentSongIndex!];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text("P L A Y I N G",
                          style: TextStyle(letterSpacing: 2)),
                      const Icon(Icons.menu),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Album Art - UPDATED TO USE NETWORK PROPERLY
                  NeuBox(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentSong
                                .albumArtPath, // Uses our dynamic URL from Provider
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // Added loading indicator
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                    height: 300,
                                    child: Icon(Icons.music_note, size: 100)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentSong.songName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(currentSong.artistName),
                                  ],
                                ),
                              ),
                              const Icon(Icons.favorite, color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Progress Bar
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatTime(position)),
                            Text(formatTime(duration)),
                          ],
                        ),
                      ),
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble() > 0
                            ? duration.inSeconds.toDouble()
                            : 1.0,
                        value: position.inSeconds.toDouble().clamp(
                            0,
                            duration.inSeconds.toDouble() > 0
                                ? duration.inSeconds.toDouble()
                                : 1.0),
                        activeColor: Colors.green,
                        onChanged: (val) async {
                          final newPosition = Duration(seconds: val.toInt());
                          await _audioPlayer.seek(newPosition);
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Playback Controls
                  Row(
                    children: [
                      // Previous Logic
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Loop to previous or just logic check
                            if (value.currentSongIndex! > 0) {
                              value.currentSongIndex =
                                  value.currentSongIndex! - 1;
                              _playCurrentSong();
                            }
                          },
                          child: const NeuBox(child: Icon(Icons.skip_previous)),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Play/Pause
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            if (isPlaying) {
                              await _audioPlayer.pause();
                            } else {
                              await _audioPlayer.resume();
                            }
                          },
                          child: NeuBox(
                            child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // ML Next Logic
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            value.playNextByMood(); // MATHEMATICAL JUMP
                            _playCurrentSong();
                          },
                          child: const NeuBox(child: Icon(Icons.skip_next)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
