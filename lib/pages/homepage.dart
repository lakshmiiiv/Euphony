import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/playlistprovider.dart';
import 'songpage.dart';
import '../components/mini_player.dart';
import '../components/neubox.dart';

import 'concert_page.dart';
import 'profile_page.dart';
import 'settingspage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
        // NEW: Coin Balance display in the AppBar
        actions: [
          Consumer<PlaylistProvider>(
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "₹${value.userCoins}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
              // --- NEW: EUPHONY BLUES PROMO BANNER ---
              Consumer<PlaylistProvider>(
                builder: (context, value, child) {
                  if (value.isEuphonyBlues) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.blue.shade900],
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "💙 EUPHONY BLUES IS LIVE 💙",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          Text(
                            "Earn 5x Coins for every 10 mins of listening!",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // SEARCH BAR
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
