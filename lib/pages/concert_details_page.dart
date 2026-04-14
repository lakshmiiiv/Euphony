import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NEW: Added for reward data
import 'package:musicapp/components/neubox.dart';
import 'package:musicapp/model/concert.dart';
import 'package:musicapp/model/playlistprovider.dart'; // NEW: Added for reward logic
import 'package:musicapp/pages/seat_selection_page.dart';
import 'package:musicapp/pages/squad_details_page.dart';

class ConcertDetailsPage extends StatelessWidget {
  final Concert concert;

  const ConcertDetailsPage({super.key, required this.concert});

  // Helper method to build squad avatars
  Widget _buildSquadAvatar(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: concert.artistName,
                child: Image.asset(
                  concert.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.artistName,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // --- NEW FEATURE: VERIFIED BADGE ---
                  Row(
                    children: [
                      Text(
                        "${concert.venue} • ${concert.date}",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const Text(" MIT Verified",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- UPDATED FEATURE: FIND MY SQUAD (NOW TAPPABLE) ---
                  const Text(
                    "Find My Squad",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SquadDetailsPage(
                            artistName: concert.artistName,
                          ),
                        ),
                      );
                    },
                    child: NeuBox(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 40,
                              child: Stack(
                                children: [
                                  _buildSquadAvatar(
                                      "JS", Colors.deepPurple.shade300),
                                  Positioned(
                                      left: 22,
                                      child: _buildSquadAvatar(
                                          "AK", Colors.blue.shade300)),
                                  Positioned(
                                      left: 44,
                                      child: _buildSquadAvatar(
                                          "RV", Colors.pink.shade300)),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "3 classmates attending",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    "B.Tech IT • 3rd Year",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- NEW FEATURE: EUPHONY BLUES SAVINGS PREVIEW ---
                  const SizedBox(height: 25),
                  Consumer<PlaylistProvider>(
                    builder: (context, provider, child) => Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Euphony Blues Loyalty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(
                                    "Use ₹${provider.userCoins} in coins for this booking",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Text("-₹${provider.userCoins}",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "About the Event",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Experience an unforgettable night of music with high-fidelity sound and immersive visuals. Secure your spot now for the best views in the house!",
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SeatSelectionPage(artistName: concert.artistName),
                        ),
                      );
                    },
                    child: NeuBox(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Consumer<PlaylistProvider>(
                            builder: (context, provider, child) => Text(
                              "Select Seats - ₹${concert.ticketPrice - provider.userCoins}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
