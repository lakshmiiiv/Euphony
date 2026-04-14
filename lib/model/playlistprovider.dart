import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'song.dart';
import '../services/api_service.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  int? _currentSongIndex;

  // --- REWARD & SQUAD SYSTEM VARIABLES ---
  int _userCoins = 0;
  int _totalSecondsPlayed = 0;

  // NEW SQUAD TWEAKS:
  bool _isProfilePrivate = false; // Loophole fix: Privacy Toggle
  String _userCollegeDomain = "@mit.edu.in"; // Loophole fix: Verification
  int _maxSquadSize = 6; // Loophole fix: Scalability

  // --- QUICK ATTENDEE VARIABLES ---
  Map<String, dynamic>? _quickAttendeeData;
  Map<String, dynamic>? get quickAttendeeData => _quickAttendeeData;

  final ApiService _apiService = ApiService();

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  int get userCoins => _userCoins;
  bool get isEuphonyBlues => DateTime.now().weekday == DateTime.friday;

  // Getters for Squad Tweaks
  bool get isProfilePrivate => _isProfilePrivate;
  int get maxSquadSize => _maxSquadSize;

  // --- QUICK ATTENDEE LOGIC ---
  Future<void> fetchQuickAttendee(String username) async {
    try {
      print("QUICK ATTENDEE: Searching for $username...");
      // Using your established Realtime Database instance
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://euphony-btech-3rdyear-default-rtdb.firebaseio.com/',
      ).ref('users/$username');

      final snapshot = await ref.get().timeout(const Duration(seconds: 10));

      if (snapshot.exists) {
        _quickAttendeeData = Map<String, dynamic>.from(snapshot.value as Map);
        print("QUICK ATTENDEE: Found ${ _quickAttendeeData!['fullName']}");
      } else {
        _quickAttendeeData = null;
        print("QUICK ATTENDEE: No user found with username $username");
      }
      notifyListeners();
    } catch (e) {
      print("QUICK ATTENDEE ERROR: $e");
      _quickAttendeeData = null;
      notifyListeners();
    }
  }

  // Helper to clear attendee data after booking is done
  void clearQuickAttendee() {
    _quickAttendeeData = null;
    notifyListeners();
  }

  // --- PRIVACY TOGGLE LOGIC ---
  void togglePrivacy(bool value) {
    _isProfilePrivate = value;
    notifyListeners();
    print(
        "PRIVACY: User is now ${_isProfilePrivate ? 'Hidden' : 'Visible'} in Squads");
  }

  // --- REWARD SYSTEM LOGIC ---
  void updateListeningTime(int seconds) {
    _totalSecondsPlayed += seconds;
    if (_totalSecondsPlayed >= 600) {
      int multiplier = isEuphonyBlues ? 5 : 1;
      _userCoins += multiplier;
      _totalSecondsPlayed = 0;
      notifyListeners();
    }
  }

  double get discountAmount => _userCoins.toDouble();

  // --- 1. FIREBASE FETCH (Intact) ---
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

  // --- 2. API SEARCH (Intact) ---
  Future<void> searchAndAddFromApi(String query) async {
    List<Song> apiSongs = await _apiService.fetchSongs(query);
    if (apiSongs.isNotEmpty) {
      _playlist.addAll(apiSongs);
      notifyListeners();
    }
  }

  // --- 3. THE ML LOGIC (Intact) ---
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
}