import 'package:flutter/material.dart';
import 'package:musicapp/components/neubox.dart';
import 'package:musicapp/components/mydrawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("P R O F I L E"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const Mydrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. PROFILE HEADER
            const NeuBox(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/images/user_profile.png'), // Add a placeholder image
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Engineering Student", // You can hardcode your name here!
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text("B.Tech IT - 3rd Year",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. BOOKING HISTORY TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "M Y  B O O K I N G S",
                style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // 3. BOOKING LIST (Placeholder for now)
            Expanded(
              child: ListView(
                children: [
                  _buildBookingTile(
                      "Coldplay: Music of the Spheres", "4 Seats", "March 25"),
                  _buildBookingTile(
                      "Diljit Dosanjh: Dil-Luminati", "2 Seats", "April 10"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(String concert, String seats, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: NeuBox(
        child: ListTile(
          title: Text(concert,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("$seats • $date"),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        ),
      ),
    );
  }
}
