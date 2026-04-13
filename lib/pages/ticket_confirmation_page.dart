import 'package:flutter/material.dart';
import '../components/neubox.dart';
import 'homepage.dart';

class TicketConfirmationPage extends StatelessWidget {
  final String artistName;
  final String seatNumber;

  const TicketConfirmationPage({
    super.key,
    required this.artistName,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("T I C K E T"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Prevents going back to seat selection
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // THE TICKET CARD
            NeuBox(
              child: Column(
                children: [
                  // Top Section: Artist & Venue
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.confirmation_number,
                            size: 40, color: Colors.deepPurple),
                        const SizedBox(height: 10),
                        Text(
                          artistName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text("Live in Concert",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  // Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(thickness: 1, color: Colors.grey),
                  ),

                  // Middle Section: Seat & Squad
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("SEAT",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text(seatNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("SQUAD",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const Text("Joined ✅",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // QR Code Placeholder
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_2,
                        size: 120, color: Colors.black),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text("SCAN AT ENTRANCE",
                        style: TextStyle(
                            letterSpacing: 2,
                            fontSize: 10,
                            color: Colors.grey)),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BACK TO HOME BUTTON
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage()),
                  (route) => false, // Clears the navigation stack
                );
              },
              child: NeuBox(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: const Center(
                    child: Text(
                      "DONE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
