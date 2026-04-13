import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'song.dart';
import '../services/api_service.dart'; // Make sure this import is here

class PlaylistProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  int? _currentSongIndex;

  // NEW: API Service Instance
  final ApiService _apiService = ApiService();

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;

  // --- 1. FIREBASE FETCH (CURATED DATA) ---
  Future<void> fetchSongsFromFirebase() async {
    try {
      print("DATABASE: Starting fetch from Realtime Database...");
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://euphony-btech-3rdyear-default-rtdb.firebaseio.com/',
      ).ref();

      final snapshot = await ref.get().timeout(const Duration(seconds: 15));

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Song> loadedSongs = [];

        data.forEach((key, value) {
          if (value is Map) {
            String title = value['title']?.toString() ?? 'Unknown';
            String dynamicUrl =
                "https://picsum.photos/seed/${title.hashCode}/400/400";

            loadedSongs.add(Song(
              songName: title,
              artistName: value['artist']?.toString() ?? 'Unknown Artist',
              audioPath: value['url']?.toString() ?? '',
              albumArtPath: value['imageUrl'] ?? dynamicUrl,
              valence: (value['valence'] ?? 0.5).toDouble(),
              bpm: (value['bpm'] ?? 100).toInt(),
              mood: value['mood']?.toString() ?? 'Neutral',
            ));
          }
        });

        _playlist = loadedSongs;
        notifyListeners();
        print("DATABASE: Successfully loaded ${_playlist.length} songs.");
      }
    } catch (e) {
      print("DATABASE ERROR: $e");
    }
  }

  // --- 2. API SEARCH (DISCOVERY DATA) ---
  Future<void> searchAndAddFromApi(String query) async {
    print("API: Searching for '$query'...");
    List<Song> apiSongs = await _apiService.fetchSongs(query);

    if (apiSongs.isNotEmpty) {
      // Option A: Replace playlist with search results
      // _playlist = apiSongs;

      // Option B: Add API results to existing Firebase songs (Recommended for B.Tech demo)
      _playlist.addAll(apiSongs);

      notifyListeners();
      print("API: Added ${apiSongs.length} new songs to the list.");
    }
  }

  // --- 3. THE ML LOGIC (Euclidean Distance) ---
  void playNextByMood() {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    Song current = _playlist[_currentSongIndex!];
    Song? bestMatch;
    double minDistance = double.infinity;

    for (int i = 0; i < _playlist.length; i++) {
      var song = _playlist[i];
      if (song.songName == current.songName) continue;

      // Distance calculation (Normalization: BPM / 200)
      double vDist = pow(song.valence - current.valence, 2).toDouble();
      double bDist = pow((song.bpm - current.bpm) / 200, 2).toDouble();
      double totalDistance = sqrt(vDist + bDist);

      if (totalDistance < minDistance) {
        minDistance = totalDistance;
        bestMatch = song;
      }
    }

    if (bestMatch != null) {
      _currentSongIndex = _playlist.indexOf(bestMatch);
      print(
          "ML SUGGESTION: Playing ${bestMatch.songName} (Score: ${minDistance.toStringAsFixed(4)})");
      notifyListeners();
    }
  }

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    notifyListeners();
  }
}
