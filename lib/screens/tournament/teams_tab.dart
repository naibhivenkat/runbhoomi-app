import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import '../teams/team_squad_screen.dart';


class TeamsTab extends StatefulWidget {
  final int tournamentId;
  final int maxTeams;

  const TeamsTab({
    required this.tournamentId,
    required this.maxTeams,
  });

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab> {
  List teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  Future<void> loadTeams() async {
    try {
      final data =
          await ApiService.getTeams(widget.tournamentId);

      if (!mounted) return;

      setState(() {
        teams = data;
      });

      if (teams.length >= widget.maxTeams) {
        Future.delayed(Duration.zero, () {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All teams added")),
          );
        });
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load teams")),
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void confirmDelete(team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Team"),
        content: Text("Remove ${team["team_name"]}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteTeam(team);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  Future<void> deleteTeam(dynamic team) async {
    HapticFeedback.mediumImpact();

    final teamId = team["id"];

    try {
      await ApiService.deleteTeam(teamId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team deleted")),
      );

      loadTeams();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }

  // ✅ UPDATED TEAM CARD WITH CLICK
  Widget buildTeamCard(dynamic t, int i) {
    final name = t["team_name"];

    return GestureDetector(
      onTap: () {
        // ✅ OPEN SQUAD SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamSquadScreen(
              teamId: t["team_id"],
              teamName: t["team_name"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.blue.withOpacity(0.08),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                name[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Team #${i + 1}",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => confirmDelete(t),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFull = teams.length >= widget.maxTeams;
    final filled = widget.maxTeams == 0
        ? 0.0
        : teams.length / widget.maxTeams;

    return Column(
      children: [

        /// 🔥 HEADER
        if (!isFull)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF2C5364),
                  Color(0xFF00c6ff),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tournament Teams",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${teams.length}/${widget.maxTeams}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: filled,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        /// 🔥 TEAM LIST
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : teams.isEmpty
                  ? const Center(
                      child: Text(
                        "No teams yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (_, i) =>
                          buildTeamCard(teams[i], i),
                    ),
        ),
      ],
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../services/api_service.dart';

// class TeamsTab extends StatefulWidget {
//   final int tournamentId;
//   final int maxTeams;

//   const TeamsTab({
//     required this.tournamentId,
//     required this.maxTeams,
//   });

//   @override
//   State<TeamsTab> createState() => _TeamsTabState();
// }

// class _TeamsTabState extends State<TeamsTab> {
//   List teams = [];
//   bool isLoading = true;
//   bool maxShown = false;

//   @override
//   void initState() {
//     super.initState();
//     loadTeams();
//   }

//   Future<void> loadTeams() async {
//     try {
//       final data =
//           await ApiService.getTeams(widget.tournamentId);

//       if (!mounted) return;

//       setState(() {
//         teams = data;

//         /// 🔥 AUTO ACTION WHEN FULL
//         if (teams.length >= widget.maxTeams && !maxShown) {
//           maxShown = true;

//           Future.delayed(Duration.zero, () {
//             if (!mounted) return;

//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("All teams added")),
//             );
//           });

//           ApiService.generateFixtures(widget.tournamentId);

//           DefaultTabController.of(context)?.animateTo(2);
//         }
//       });
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to load teams")),
//       );
//     }

//     if (!mounted) return;
//     setState(() => isLoading = false);
//   }

//   void confirmDelete(team) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Delete Team"),
//         content: Text("Remove ${team["team_name"]}?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               deleteTeam(team);
//             },
//             child: const Text("Delete"),
//           )
//         ],
//       ),
//     );
//   }

//   Future<void> deleteTeam(dynamic team) async {
//     HapticFeedback.mediumImpact();

//     final teamId = team["id"];

//     try {
//       await ApiService.deleteTeam(teamId);

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Team deleted")),
//       );

//       loadTeams();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Delete failed")),
//       );
//     }
//   }

//   Widget buildTeamCard(dynamic t, int i) {
//     final name = t["team_name"];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white,
//             Colors.blue.shade50,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 20,
//             color: Colors.blue.withOpacity(0.08),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: Colors.blue.shade100,
//             child: Text(
//               name[0],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   "Team #${i + 1}",
//                   style: const TextStyle(
//                     color: Colors.black54,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.redAccent),
//             onPressed: () => confirmDelete(t),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isFull = teams.length >= widget.maxTeams;
//     final filled = widget.maxTeams == 0
//         ? 0.0
//         : teams.length / widget.maxTeams;

//     return Column(
//       children: [

//         /// 🔥 HEADER
//         if (!isFull)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xFF0F2027),
//                   Color(0xFF2C5364),
//                   Color(0xFF00c6ff),
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.4),
//                   blurRadius: 20,
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Tournament Teams",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "${teams.length}/${widget.maxTeams}",
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 10),

//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: filled,
//                     minHeight: 8,
//                     backgroundColor: Colors.white24,
//                     color: Colors.greenAccent,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         const SizedBox(height: 10),

//         /// 🔥 TEAM LIST (NO ANIMATION → NO CRASH)
//         Expanded(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : teams.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No teams yet",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: teams.length,
//                       itemBuilder: (_, i) =>
//                           buildTeamCard(teams[i], i),
//                     ),
//         ),
//       ],
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../services/api_service.dart';

// class TeamsTab extends StatefulWidget {
//   final int tournamentId;
//   final int maxTeams;

//   const TeamsTab({
//     required this.tournamentId,
//     required this.maxTeams,
//   });

//   @override
//   State<TeamsTab> createState() => _TeamsTabState();
// }

// class _TeamsTabState extends State<TeamsTab> {
//   List teams = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadTeams();
//   }

//   Future<void> loadTeams() async {
//     try {
//       final data =
//           await ApiService.getTeams(widget.tournamentId);

//       if (!mounted) return;

//       setState(() {
//         teams = data;
//       });

//       // ✅ ONLY SHOW MESSAGE (NO AUTO ACTION)
//       if (teams.length >= widget.maxTeams) {
//         Future.delayed(Duration.zero, () {
//           if (!mounted) return;

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("All teams added")),
//           );
//         });
//       }

//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to load teams")),
//       );
//     }

//     if (!mounted) return;
//     setState(() => isLoading = false);
//   }

//   void confirmDelete(team) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Delete Team"),
//         content: Text("Remove ${team["team_name"]}?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               deleteTeam(team);
//             },
//             child: const Text("Delete"),
//           )
//         ],
//       ),
//     );
//   }

//   Future<void> deleteTeam(dynamic team) async {
//     HapticFeedback.mediumImpact();

//     final teamId = team["id"];

//     try {
//       await ApiService.deleteTeam(teamId);

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Team deleted")),
//       );

//       loadTeams();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Delete failed")),
//       );
//     }
//   }

//   Widget buildTeamCard(dynamic t, int i) {
//     final name = t["team_name"];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white,
//             Colors.blue.shade50,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 20,
//             color: Colors.blue.withOpacity(0.08),
//           )
//         ],
//       ),
      
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: Colors.blue.shade100,
//             child: Text(
//               name[0],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   "Team #${i + 1}",
//                   style: const TextStyle(
//                     color: Colors.black54,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.redAccent),
//             onPressed: () => confirmDelete(t),
//           )
//         ],
//       ),
//     );
    
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isFull = teams.length >= widget.maxTeams;
//     final filled = widget.maxTeams == 0
//         ? 0.0
//         : teams.length / widget.maxTeams;

//     return Column(
//       children: [

//         /// 🔥 HEADER
//         if (!isFull)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xFF0F2027),
//                   Color(0xFF2C5364),
//                   Color(0xFF00c6ff),
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.4),
//                   blurRadius: 20,
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Tournament Teams",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "${teams.length}/${widget.maxTeams}",
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 10),

//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: filled,
//                     minHeight: 8,
//                     backgroundColor: Colors.white24,
//                     color: Colors.greenAccent,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         const SizedBox(height: 10),

//         /// 🔥 TEAM LIST
//         Expanded(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : teams.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No teams yet",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: teams.length,
//                       itemBuilder: (_, i) =>
//                           buildTeamCard(teams[i], i),
//                     ),
//         ),
//       ],
//     );
//   }
// }
