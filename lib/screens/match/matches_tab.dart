// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import 'match_setup_screen.dart';


// class MatchesTab extends StatefulWidget {
//   final int tournamentId;

//   const MatchesTab({super.key, required this.tournamentId});

//   @override
//   State<MatchesTab> createState() => _MatchesTabState();
// }

// class _MatchesTabState extends State<MatchesTab> {
//   List matches = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadMatches();
//   }

//   Future<void> loadMatches() async {
//     try {
//       final data =
//           await ApiService.getTournamentMatches(widget.tournamentId);

//       if (!mounted) return;

//       setState(() {
//         matches = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() => isLoading = false);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to load matches")),
//       );
//     }
//   }

// Future<void> generateFixtures() async {
//   try {
//     await ApiService.generateFixtures(widget.tournamentId);
//     loadMatches();
//   } catch (e) {

//     // ✅ HANDLE 400 ERROR
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Fixtures already generated")),
//     );
//   }
// }


// Future<void> openMatchSetup(Map m) async {
//   try {
//     final res =
//         await ApiService.initMatchFromFixture(m["id"]);

//     final matchId = res["match_id"];

//     // ✅ SAFETY FIX
//     if (matchId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Match not initialized")),
//       );
//       return;
//     }

//     if (!mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MatchSetupScreen(
//           matchId: matchId,

//           // ✅ SAFE IDs
//           teamAId: m["team_a_id"] ?? 0,
//           teamBId: m["team_b_id"] ?? 0,

//           // ✅ SAFE names
//           teamAName: m["team_a"] ?? "Team A",
//           teamBName: m["team_b"] ?? "Team B",
//         ),
//       ),
//     );
//   } catch (e) {
//     debugPrint("Error opening setup: $e");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Failed to open match setup")),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//         /// 🔥 BUTTON
//         Padding(
//           padding: const EdgeInsets.all(10),
//           child: ElevatedButton(
//             onPressed: generateFixtures,
//             child: const Text("Generate Fixtures"),
//           ),
//         ),

//         /// 🔥 LIST
//         Expanded(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : matches.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No matches yet",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: matches.length,
//                       itemBuilder: (_, i) {
//                         final m = matches[i];

//                         return Card(
//                           margin: const EdgeInsets.all(10),
//                           child: ListTile(
//                             title: Text(
//                               "${m["team_a"]} vs ${m["team_b"]}",
//                             ),
//                             subtitle: Text(m["stage"] ?? ""),

//                             // ✅ TAP → SETUP FLOW
//                             onTap: () => openMatchSetup(m),

//                             trailing: m["winner"] != null
//                                 ? Text(
//                                     "Winner: ${m["winner"]}",
//                                     style: const TextStyle(
//                                       color: Colors.green,
//                                     ),
//                                   )
//                                 : const Text("Upcoming"),
//                           ),
//                         );
//                       },
//                     ),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'match_setup_screen.dart';

class MatchesTab extends StatefulWidget {
  final int tournamentId;

  const MatchesTab({super.key, required this.tournamentId});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  List matches = [];
  bool isLoading = true;

  // ✅ NEW: track if fixtures exist
  bool fixturesGenerated = false;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      final data =
          await ApiService.getTournamentMatches(widget.tournamentId);

      if (!mounted) return;

      setState(() {
        matches = data;
        isLoading = false;

        // ✅ FIX: detect if fixtures exist
        fixturesGenerated = data.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load matches")),
      );
    }
  }

  // ✅ GENERATE FIXTURES
  Future<void> generateFixtures() async {
    try {
      await ApiService.generateFixtures(widget.tournamentId);

      // reload matches
      await loadMatches();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fixtures generated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fixtures already generated")),
      );
    }
  }

  // ✅ OPEN MATCH SETUP
  Future<void> openMatchSetup(Map m) async {
    try {
      final res =
          await ApiService.initMatchFromFixture(m["id"]);

      final matchId = res["match_id"];

      if (matchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Match not initialized")),
        );
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchSetupScreen(
            matchId: matchId,
            teamAId: m["team_a_id"] ?? 0,
            teamBId: m["team_b_id"] ?? 0,
            teamAName: m["team_a"] ?? "Team A",
            teamBName: m["team_b"] ?? "Team B",
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error opening setup: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open match setup")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// 🔥 SHOW BUTTON ONLY IF NO FIXTURES
        if (!fixturesGenerated)
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: generateFixtures,
              child: const Text("Generate Fixtures"),
            ),
          ),

        /// 🔥 MATCH LIST
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : matches.isEmpty
                  ? const Center(
                      child: Text(
                        "No matches yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (_, i) {
                        final m = matches[i];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              "${m["team_a"]} vs ${m["team_b"]}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),

                            subtitle: Text(
                              m["stage"] ?? "Match",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            onTap: () => openMatchSetup(m),

                            trailing: m["winner"] != null
                                ? Text(
                                    "Winner: ${m["winner"]}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text(
                                    "Upcoming",
                                    style: TextStyle(color: Colors.orange),
                                  ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}