import 'package:flutter/material.dart';
import '../../models/tournament_model.dart';
import '../../services/api_service.dart';
import 'create_tournament_screen.dart';
import 'tournament_detail_screen.dart';

class TournamentListScreen extends StatefulWidget {
  @override
  State<TournamentListScreen> createState() =>
      _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  late Future<List<Tournament>> tournaments;

  @override
  void initState() {
    super.initState();
    tournaments = ApiService.getTournaments();
  }

  void refresh() {
    setState(() {
      tournaments = ApiService.getTournaments();
    });
  }

  Color getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case "t20":
        return Colors.orange;
      case "test":
        return Colors.blue;
      case "100":
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Tournaments"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTournamentScreen(),
            ),
          );
          refresh();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Create"),
      ),

      body: FutureBuilder<List<Tournament>>(
        future: tournaments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("No tournaments yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TournamentDetailScreen(tournament: t),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: t.bannerUrl != null
                        ? DecorationImage(
                            image: NetworkImage(t.bannerUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: t.bannerUrl == null
                        ? const LinearGradient(
                            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.45),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [

                          /// LOGO
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: t.logoUrl != null
                                  ? Image.network(
                                      t.logoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.emoji_events,
                                              color: Colors.orange),
                                    )
                                  : const Icon(Icons.emoji_events,
                                      color: Colors.orange),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  t.location,
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Text("${t.totalTeams ?? 0} Teams",
                                        style: const TextStyle(color: Colors.white)),

                                    const SizedBox(width: 10),

                                    Text(t.type.toUpperCase(),
                                        style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              );
            },
          );
        },
      ),
    );
  }
}