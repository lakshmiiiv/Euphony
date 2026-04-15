import 'dart:async'; // NEW: Required for the Reward Timer
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'song.dart';
import '../services/api_service.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  int? _currentSongIndex;
  bool _isPlaying = false;

  // --- REWARD & SQUAD SYSTEM VARIABLES ---
  int _userCoins = 0;
  int _totalSecondsPlayed = 0;
  Timer? _rewardTimer; // NEW: Global Timer for Reward Tracking

  // NEW SQUAD TWEAKS:
  bool _isProfilePrivate = false;
  String _userCollegeDomain = "@mit.edu.in";
  int _maxSquadSize = 6;

  // --- QUICK ATTENDEE VARIABLES ---
  Map<String, dynamic>? _quickAttendeeData;
  Map<String, dynamic>? get quickAttendeeData => _quickAttendeeData;

  final ApiService _apiService = ApiService();

  // Getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  int get userCoins => _userCoins;
  bool get isPlaying => _isPlaying;
  bool get isEuphonyBlues => DateTime.now().weekday == DateTime.friday;
  bool get isProfilePrivate => _isProfilePrivate;
  int get maxSquadSize => _maxSquadSize;

  // --- NEW: TIMER CONTROL LOGIC ---
  // Call this in your SongPage when play is pressed
  void startRewardTimer() {
    _rewardTimer?.cancel(); // Safety reset
    _rewardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        updateListeningTime(1);
      }
    });
  }

  void stopRewardTimer() {
    _rewardTimer?.cancel();
  }

  // --- REWARD SYSTEM LOGIC (EXPANDED) ---
  void updateListeningTime(int seconds) {
    _totalSecondsPlayed += seconds;

    // Logic: Every 10 seconds = Reward
    if (_totalSecondsPlayed >= 10) {
      int multiplier = isEuphonyBlues ? 5 : 1;
      _userCoins += multiplier;
      _totalSecondsPlayed = 0;

      // PERSISTENCE LOGIC: For the research paper, we call this "Atomic Cloud Updates"
      // syncCoinsWithFirebase();

      notifyListeners();
    }
  }

  /* set isPlaying(bool value) {
    _isPlaying = value;
    if (_isPlaying) {
      startRewardTimer();
    } else {
      stopRewardTimer();
    }
    notifyListeners();
  }*/

  set isPlaying(bool value) {
    _isPlaying = value;

    // SAFETY: Kill any existing timer so they don't stack up
    _rewardTimer?.cancel();

    if (_isPlaying) {
      print("DEBUG: Music Playing - Timer Started");
      _rewardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Only update if the music is still actually playing
        if (_isPlaying) {
          updateListeningTime(1);
          // Check your VS Code Debug Console for this print!
          print("DEBUG: Seconds: $_totalSecondsPlayed | Coins: $_userCoins");
        } else {
          timer.cancel();
        }
      });
    } else {
      print("DEBUG: Music Paused - Timer Stopped");
    }

    notifyListeners();
  }

  // --- QUICK ATTENDEE LOGIC ---
  Future<void> fetchQuickAttendee(String username) async {
    try {
      print("QUICK ATTENDEE: Searching for $username...");
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://euphony-btech-3rdyear-default-rtdb.firebaseio.com/',
      ).ref('users/$username');

      final snapshot = await ref.get().timeout(const Duration(seconds: 10));

      if (snapshot.exists) {
        _quickAttendeeData = Map<String, dynamic>.from(snapshot.value as Map);
        print("QUICK ATTENDEE: Found ${_quickAttendeeData!['fullName']}");
      } else {
        _quickAttendeeData = null;
      }
      notifyListeners();
    } catch (e) {
      print("QUICK ATTENDEE ERROR: $e");
      _quickAttendeeData = null;
      notifyListeners();
    }
  }

  void clearQuickAttendee() {
    _quickAttendeeData = null;
    notifyListeners();
  }

  // --- PRIVACY TOGGLE LOGIC ---
  void togglePrivacy(bool value) {
    _isProfilePrivate = value;
    notifyListeners();
  }

  double get discountAmount => _userCoins.toDouble();

  // --- FIREBASE FETCH ---
  Future<void> fetchSongsFromFirebase() async {
    try {
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
            loadedSongs.add(Song(
              songName: title,
              artistName: value['artist']?.toString() ?? 'Unknown Artist',
              audioPath: value['url']?.toString() ?? '',
              albumArtPath: value['imageUrl'] ??
                  "https://picsum.photos/seed/${title.hashCode}/400/400",
              valence: (value['valence'] ?? 0.5).toDouble(),
              bpm: (value['bpm'] ?? 100).toInt(),
              mood: value['mood']?.toString() ?? 'Neutral',
            ));
          }
        });
        _playlist = loadedSongs;
        notifyListeners();
      }
    } catch (e) {
      print("DATABASE ERROR: $e");
    }
  }

  // --- API SEARCH ---
  Future<void> searchAndAddFromApi(String query) async {
    List<Song> apiSongs = await _apiService.fetchSongs(query);
    if (apiSongs.isNotEmpty) {
      _playlist.addAll(apiSongs);
      notifyListeners();
    }
  }

  // --- ML MOOD LOGIC ---
  void playNextByMood() {
    if (_currentSongIndex == null || _playlist.isEmpty) return;
    Song current = _playlist[_currentSongIndex!];
    Song? bestMatch;
    double minDistance = double.infinity;

    for (var song in _playlist) {
      if (song.songName == current.songName) continue;
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
      notifyListeners();
    }
  }

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    notifyListeners();
  }

  @override
  void dispose() {
    _rewardTimer?.cancel(); // Prevent memory leaks
    super.dispose();
  }
}
