import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/song.dart';

class ApiService {
  // The base URL for iTunes Search
  static const String _baseUrl = "https://itunes.apple.com/search";

  Future<List<Song>> fetchSongs(String searchTerm) async {
    // 1. Construct the URL with the search term
    final url = Uri.parse("$_baseUrl?term=$searchTerm&entity=song&limit=10");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 2. Decode the JSON
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> results = data['results'];

        // 3. Map JSON results to your Song Model
        return results.map((json) {
          return Song(
            songName: json['trackName'] ?? "Unknown",
            artistName: json['artistName'] ?? "Unknown",
            // Getting a high-res version of the cover (600x600 instead of 100x100)
            albumArtPath: json['artworkUrl100']
                .toString()
                .replaceAll('100x100bb', '600x600bb'),
            audioPath: json['previewUrl'] ?? "",
            // Default values for your ML logic (APIs don't usually provide these)
            bpm: 120,
            valence: 0.5,
            mood: "Discover",
          );
        }).toList();
      } else {
        throw Exception("Failed to load music");
      }
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }
}
