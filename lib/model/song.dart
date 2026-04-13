class Song {
  final String songName;
  final String artistName;
  final String albumArtPath;
  final String audioPath;
  final double valence; // New
  final int bpm; // New
  final String mood; // New

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtPath,
    required this.audioPath,
    required this.valence,
    required this.bpm,
    required this.mood,
  });
}
