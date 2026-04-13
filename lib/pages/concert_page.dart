import 'package:flutter/material.dart';
import 'package:musicapp/components/neubox.dart';
import 'package:musicapp/model/concert.dart';
import 'package:musicapp/pages/concert_details_page.dart';

class ConcertPage extends StatelessWidget {
  const ConcertPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data (Make sure these image paths exist in your assets folder!)
    List<Concert> concerts = [
      Concert(
        artistName: "Kendrick Lamar",
        venue: "Madison Square Garden",
        date: "25th Oct, 2026",
        imagePath: "assets/images/620018f7-82eb-4044-8228-da501908e77a...",
        ticketPrice: 150.0,
        isTrending: true,
      ),
      Concert(
        artistName: "The Beatles (Tribute)",
        venue: "Abbey Road Studios",
        date: "12th Nov, 2026",
        imagePath: "assets/images/THE BEATLES - Abbey Road (1969).jpeg",
        ticketPrice: 80.0,
      ),
    ];

    return Scaffold(
      // FIXED: Changed .background to .surface for SDK 35
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("D I S C O V E R  E V E N T S"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Text("Trending Near You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // Horizontal Trending List
          SizedBox(
            height: 250, // Increased height slightly for better spacing
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: concerts.length,
              itemBuilder: (context, index) {
                final concert = concerts[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ConcertDetailsPage(concert: concert)),
                    ),
                    child: NeuBox(
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  concert.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(concert.artistName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(concert.date,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
            child: Text("All Concerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // Vertical All Concerts List
          Expanded(
            child: ListView.builder(
              itemCount: concerts.length,
              itemBuilder: (context, index) {
                final concert = concerts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 10),
                  child: NeuBox(
                    child: ListTile(
                      title: Text(concert.artistName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text("${concert.venue} • \$${concert.ticketPrice}"),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.primary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConcertDetailsPage(concert: concert),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
