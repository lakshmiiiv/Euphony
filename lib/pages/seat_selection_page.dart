import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/components/neubox.dart';
import 'package:musicapp/pages/ticket_confirmation_page.dart';
import 'package:musicapp/model/playlistprovider.dart';

class SeatSelectionPage extends StatefulWidget {
  final String artistName;
  const SeatSelectionPage({super.key, required this.artistName});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  // Logic: 40 seats. seatStatus: false = Available, true = User Selected
  List<bool> seatStatus = List.generate(40, (index) => false);

  // SQUAD LOGIC (Hardcoded for Demo)
  bool hasJoinedSquad = true;
  final List<int> squadSeats = [12, 13, 14];

  // --- FEATURE: QUICK ATTENDEE MODAL ---
  void _showBookingForm(BuildContext context, int selectedCount) {
    final TextEditingController _searchController = TextEditingController();

    // Form Controllers
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 25,
            right: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Q U I C K  A T T E N D E E",
                  style:
                      TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter friend's username...",
                  prefixIcon: const Icon(Icons.person_search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.deepPurple),
                    onPressed: () {
                      Provider.of<PlaylistProvider>(context, listen: false)
                          .fetchQuickAttendee(_searchController.text);
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Form Fields
              Consumer<PlaylistProvider>(
                builder: (context, provider, child) {
                  final friend = provider.quickAttendeeData;

                  if (friend != null) {
                    _nameController.text = friend['fullName'] ?? "";
                    _emailController.text = friend['email'] ?? "";
                    _phoneController.text = friend['phone'] ?? "";
                    _ageController.text = friend['age']?.toString() ?? "";
                  }

                  return Column(
                    children: [
                      _buildAttendeeField(
                          "Full Name", Icons.person, _nameController),
                      _buildAttendeeField(
                          "Email Address", Icons.email, _emailController),
                      Row(
                        children: [
                          Expanded(
                              child: _buildAttendeeField(
                                  "Phone", Icons.phone, _phoneController)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildAttendeeField(
                                  "Age", Icons.calendar_today, _ageController)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                        },
                        child: NeuBox(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            width: double.infinity,
                            child: const Center(
                              child: Text("C O N F I R M  B O O K I N G",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeField(
      String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                    "Available", Theme.of(context).colorScheme.secondary),
                _buildLegendItem("Selected", Colors.green),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Occupied seat.")));
                        return;
                      }
                      setState(() {
                        seatStatus[index] = !isSelected;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: seatColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                          isSquadSeat && hasJoinedSquad
                              ? Icons.group
                              : Icons.chair,
                          size: 20,
                          color: (isSelected || (isSquadSeat && hasJoinedSquad))
                              ? Colors.white
                              : Colors.grey.shade500),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: GestureDetector(
              onTap: () {
                int selectedCount = seatStatus.where((s) => s).length;
                if (selectedCount > 0) {
                  _showBookingForm(context, selectedCount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select a seat first!")));
                }
              },
              child: NeuBox(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text("CONFIRM BOOKING",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
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
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
