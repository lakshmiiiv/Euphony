import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/playlistprovider.dart';
import 'songpage.dart';
import '../components/mini_player.dart';
import '../components/neubox.dart'; // Ensure NeuBox is imported

import 'concert_page.dart';
import 'profile_page.dart';
import 'settingspage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // NEW: Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaylistProvider>(context, listen: false)
          .fetchSongsFromFirebase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("E U P H O N Y",
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.music_note,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("P R O F I L E"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text("C O N C E R T S"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConcertPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("S E T T I N G S"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // --- NEW: SEARCH BAR FEATURE ---
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: NeuBox(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search global music...",
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Provider.of<PlaylistProvider>(context, listen: false)
                            .searchAndAddFromApi(value);
                        _searchController.clear();

                        // Show a small feedback snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Searching for '$value'...")),
                        );
                      }
                    },
                  ),
                ),
              ),

              // THE PLAYLIST
              Expanded(
                child: Consumer<PlaylistProvider>(
                  builder: (context, value, child) {
                    final playlist = value.playlist;

                    if (playlist.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: playlist.length,
                      padding: const EdgeInsets.only(bottom: 110, top: 10),
                      itemBuilder: (context, index) {
                        final song = playlist[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: ListTile(
                            tileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            title: Text(song.songName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(song.artistName),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song.albumArtPath,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.music_note),
                              ),
                            ),
                            onTap: () {
                              value.currentSongIndex = index;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Songpage()));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // MINI PLAYER
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: MiniPlayer(),
            ),
          ),
        ],
      ),
    );
  }
}
