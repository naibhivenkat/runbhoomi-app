// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import 'add_player_screen.dart';

// class TeamSquadScreen extends StatefulWidget {
//   final int teamId;
//   final String teamName;

//   const TeamSquadScreen({
//     super.key,
//     required this.teamId,
//     required this.teamName,
//   });

//   @override
//   State<TeamSquadScreen> createState() => _TeamSquadScreenState();
// }

// class _TeamSquadScreenState extends State<TeamSquadScreen> {
//   List players = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadPlayers();
//   }

//   Future<void> loadPlayers() async {
//     try {
//       final data = await ApiService.getTeamPlayers(widget.teamId);

//       if (!mounted) return;

//       setState(() {
//         players = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   /// ✅ ADD PLAYER FLOW
//   void openAddPlayer() async {
//     final res = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddPlayerScreen(teamId: widget.teamId),
//       ),
//     );

//     if (res != null) {
//       loadPlayers();
//     }
//   }

//   /// ✅ INVITE PLAYER FLOW
//   Future<void> generateInvite() async {
//     try {
//       final res = await ApiService.createInvite(widget.teamId);

//       final code = res["code"];

//       if (!mounted) return;

//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Invite Player"),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("Share this code with players"),
//               const SizedBox(height: 12),

//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   code,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Close"),
//             )
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint("Invite error: $e");

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to generate invite")),
//       );
//     }
//   }

//   /// ✅ PLAYER CARD
//   Widget buildPlayer(dynamic p, int i) {
//     final name = p["name"] ?? "Player";

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white,
//             Colors.green.shade50,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: Colors.green.withOpacity(0.08),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.green.shade100,
//             child: Text(name[0]),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               name,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Text(
//             "#${i + 1}",
//             style: const TextStyle(color: Colors.grey),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${widget.teamName} Squad"),
//       ),

//       /// ✅ TOP ACTION BUTTONS (NEW)
//       body: Column(
//         children: [

//           /// 🔥 ACTION BAR
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: openAddPlayer,
//                     icon: const Icon(Icons.person_add),
//                     label: const Text("Add Player"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: generateInvite,
//                     icon: const Icon(Icons.link),
//                     label: const Text("Invite"),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// 🔥 PLAYER LIST
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : players.isEmpty
//                     ? const Center(
//                         child: Text(
//                           "No players yet",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: players.length,
//                         itemBuilder: (_, i) =>
//                             buildPlayer(players[i], i),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_player_screen.dart';
import 'playing_xi_screen.dart';


class TeamSquadScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  const TeamSquadScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TeamSquadScreen> createState() => _TeamSquadScreenState();
}

class _TeamSquadScreenState extends State<TeamSquadScreen> {
  List players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  ////////////////////////////////////////////////////////////
  /// LOAD PLAYERS
  ////////////////////////////////////////////////////////////
  Future<void> loadPlayers() async {
    try {
      final data = await ApiService.getTeamPlayers(widget.teamId);

      if (!mounted) return;

      setState(() {
        players = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  ////////////////////////////////////////////////////////////
  /// ADD PLAYER
  ////////////////////////////////////////////////////////////
  void openAddPlayer() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPlayerScreen(teamId: widget.teamId),
      ),
    );

    if (res != null) {
      loadPlayers(); // ✅ refresh list
    }
  }

  ////////////////////////////////////////////////////////////
  /// PLAYING XI (NEW)
  ////////////////////////////////////////////////////////////
  void openPlayingXI() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayingXIScreen(
          matchId: 1, // ⚠️ TODO: pass real matchId
          teamId: widget.teamId,
        ),
      ),
    );

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Playing XI saved")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  /// INVITE PLAYER
  ////////////////////////////////////////////////////////////
  Future<void> generateInvite() async {
    try {
      final res = await ApiService.createInvite(widget.teamId);

      final code = res["code"];

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invite Player"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Share this code with players"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        ),
      );
    } catch (e) {
      debugPrint("Invite error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to generate invite")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  /// PLAYER CARD
  ////////////////////////////////////////////////////////////
  Widget buildPlayer(dynamic p, int i) {
    final name = p["name"] ?? "Player";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.green.withOpacity(0.08),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "#${i + 1}",
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.teamName} Squad"),
      ),
      body: Column(
        children: [

          ////////////////////////////////////////////////////////////
          /// 🔥 ACTION BAR (UPDATED)
          ////////////////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: openAddPlayer,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: generateInvite,
                    icon: const Icon(Icons.link),
                    label: const Text("Invite"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: players.length < 11 ? null : openPlayingXI,
                    icon: const Icon(Icons.sports_cricket),
                    label: const Text("Playing XI"),
                  ),
                ),
              ],
            ),
          ),

          ////////////////////////////////////////////////////////////
          /// PLAYER LIST
          ////////////////////////////////////////////////////////////
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : players.isEmpty
                    ? const Center(
                        child: Text(
                          "No players yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (_, i) =>
                            buildPlayer(players[i], i),
                      ),
          ),
        ],
      ),
    );
  }
}