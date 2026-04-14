import 'dart:async'; // NEW: Required for the reward timer
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

  // NEW: Timer to track listening seconds for rewards
  Timer? _rewardTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to player state (playing/paused)
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state == PlayerState.playing);

        // REWARD FEATURE: Start or stop timer based on playback
        if (isPlaying) {
          _startRewardTimer();
        } else {
          _rewardTimer?.cancel();
        }
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

  // NEW: Reward Timer Logic
  void _startRewardTimer() {
    _rewardTimer?.cancel(); // Clear any existing timer
    _rewardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying) {
        // Update the provider every second
        Provider.of<PlaylistProvider>(context, listen: false)
            .updateListeningTime(1);
      }
    });
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
    _rewardTimer?.cancel(); // NEW: Clean up timer to prevent memory leaks
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

                      // REWARD UI: Shows current coin balance in AppBar
                      Row(
                        children: [
                          const Icon(Icons.stars,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "₹${value.userCoins}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Euphony Blues Active Banner
                  if (value.isEuphonyBlues)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: const Center(
                        child: Text(
                          "💙 EUPHONY BLUES: 5X COINS ACTIVE",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  // Album Art
                  NeuBox(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentSong.albumArtPath,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            value.playNextByMood();
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
