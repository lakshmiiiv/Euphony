import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicapp/components/neubox.dart';

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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Stack(
            children: [
              // Background "Glow" for the glass effect
              Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
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
                    height: 500,
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
                            const Icon(Icons.confirmation_number, size: 50),
                            const SizedBox(height: 20),
                            Text(artistName,
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold)),
                            const Text("ADMIT ONE",
                                style: TextStyle(letterSpacing: 4)),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
