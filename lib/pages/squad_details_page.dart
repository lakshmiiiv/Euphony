import 'package:flutter/material.dart';
import '../components/neubox.dart';

class SquadDetailsPage extends StatefulWidget {
  final String artistName;

  const SquadDetailsPage({super.key, required this.artistName});

  @override
  State<SquadDetailsPage> createState() => _SquadDetailsPageState();
}

class _SquadDetailsPageState extends State<SquadDetailsPage> {
  bool isJoined = false;

  // Dummy list of classmates
  final List<Map<String, String>> squadMembers = [
    {
      "name": "John Smith",
      "initials": "JS",
      "branch": "B.Tech IT",
      "year": "3rd Year"
    },
    {
      "name": "Ananya Kapoor",
      "initials": "AK",
      "branch": "B.Tech IT",
      "year": "3rd Year"
    },
    {
      "name": "Rahul Verma",
      "initials": "RV",
      "branch": "B.Tech IT",
      "year": "3rd Year"
    },
  ];

  void _toggleJoinSquad() {
    setState(() {
      isJoined = !isJoined;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isJoined
            ? "You've joined the squad for ${widget.artistName}!"
            : "You've left the squad."),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("S Q U A D - ${widget.artistName}"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Connect with classmates attending this event.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // JOIN SQUAD BUTTON
            GestureDetector(
              onTap: _toggleJoinSquad,
              child: NeuBox(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isJoined ? Colors.green.withOpacity(0.1) : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isJoined ? Icons.check_circle : Icons.group_add,
                          color: isJoined
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isJoined ? "YOU ARE IN THE SQUAD" : "JOIN THE SQUAD",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isJoined
                                ? Colors.green
                                : Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "SQUAD MEMBERS",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: squadMembers.length,
                itemBuilder: (context, index) {
                  final member = squadMembers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: NeuBox(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            member['initials']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          member['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("${member['branch']} • ${member['year']}"),
                        trailing:
                            const Icon(Icons.chat_bubble_outline, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
