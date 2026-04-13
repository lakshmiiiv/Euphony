import 'package:flutter/material.dart';
import 'package:musicapp/components/neubox.dart';
import 'package:musicapp/pages/ticket_confirmation_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final String artistName;
  const SeatSelectionPage({super.key, required this.artistName});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  // Logic: 40 seats. seatStatus: false = Available, true = User Selected
  List<bool> seatStatus = List.generate(40, (index) => false);

  // SQUAD LOGIC
  // In a real app, 'hasJoinedSquad' would come from your ThemeProvider or a UserProvider
  bool hasJoinedSquad = true;
  final List<int> squadSeats = [12, 13, 14];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Select Seats: ${widget.artistName}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Legend / Key (Conditional Legend)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                    "Available", Theme.of(context).colorScheme.secondary),
                _buildLegendItem("Selected", Colors.green),
                // Only show "Squad" in the legend if the user has joined
                if (hasJoinedSquad)
                  _buildLegendItem("Squad", Colors.deepPurple.shade300)
                else
                  _buildLegendItem("Occupied", Colors.grey.shade400),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("S T A G E",
              style: TextStyle(
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const Divider(indent: 80, endIndent: 80, thickness: 3),

          const SizedBox(height: 20),

          // The Seat Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: GridView.builder(
                itemCount: 40,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  bool isSquadSeat = squadSeats.contains(index);
                  bool isSelected = seatStatus[index];

                  // COLOR LOGIC: If it's a squad seat but user hasn't joined, show it as grey (Occupied)
                  Color seatColor;
                  if (isSquadSeat) {
                    seatColor = hasJoinedSquad
                        ? Colors.deepPurple.shade300
                        : Colors.grey.shade400;
                  } else if (isSelected) {
                    seatColor = Colors.green;
                  } else {
                    seatColor = Theme.of(context).colorScheme.secondary;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isSquadSeat) {
                        String message = hasJoinedSquad
                            ? "This seat is taken by your squad member!"
                            : "This seat is already occupied.";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        return;
                      }
                      setState(() {
                        seatStatus[index] = !isSelected;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: seatColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        // ICON LOGIC: Only show group icon if squad is joined
                        isSquadSeat && hasJoinedSquad
                            ? Icons.group
                            : Icons.chair,
                        size: 20,
                        color: (isSelected || (isSquadSeat && hasJoinedSquad))
                            ? Colors.white
                            : Colors.grey.shade500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Summary / Navigation
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: GestureDetector(
              onTap: () {
                int selectedCount = seatStatus.where((s) => s == true).length;

                if (selectedCount > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketConfirmationPage(
                        artistName: widget.artistName,
                        seatNumber:
                            "Row ${(seatStatus.indexOf(true) / 5).floor() + 1}, Seat ${(seatStatus.indexOf(true) % 5) + 1}",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select at least one seat!")),
                  );
                }
              },
              child: NeuBox(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Seats: ${seatStatus.where((s) => s).length}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "CONFIRM BOOKING",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
