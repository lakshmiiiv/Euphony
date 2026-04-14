import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NEW: Required for reward data
import 'package:musicapp/components/neubox.dart';
import '../model/playlistprovider.dart'; // Ensure correct path to your provider

class TicketPage extends StatelessWidget {
  final String artistName;
  final int seatCount;

  const TicketPage(
      {super.key, required this.artistName, required this.seatCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Y O U R  T I C K E T"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // NEW: Action button to "Download" or "Share" the ticket
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ticket saved to Gallery ✅")),
              );
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Stack(
            children: [
              // Background "Glow" for the glass effect
              Container(
                width: double.infinity,
                height: 550, // Slightly increased to fit reward info
                decoration: BoxDecoration(
                  color: Colors.blueAccent
                      .withOpacity(0.1), // Changed to Blue for Euphony Blues
                  borderRadius: BorderRadius.circular(40),
                ),
              ),

              // The Glass Ticket
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    height: 550, // Slightly increased
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.confirmation_number,
                                size: 50, color: Colors.blueAccent),
                            const SizedBox(height: 20),
                            Text(artistName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            const Text("ADMIT ONE",
                                style: TextStyle(
                                    letterSpacing: 4,
                                    color: Colors.blueAccent)),
                          ],
                        ),

                        // Ticket Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ticketInfo("SEATS", seatCount.toString()),
                            _ticketInfo("GATE", "B2"),
                            _ticketInfo("DATE", "OCT 25"),
                          ],
                        ),

                        // --- NEW: EUPHONY BLUES REWARD SUMMARY ---
                        Consumer<PlaylistProvider>(
                          builder: (context, value, child) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "Saved ₹${value.discountAmount} with Coins",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Fake QR Code Area
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_2,
                              color: Colors.black, size: 100),
                        ),

                        const Text("Scan at Venue Entrance",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
