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
      final data = await ApiService.getTeams(widget.tournamentId);

      if (!mounted) return;

      setState(() {
        teams = List.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load teams")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  /// ❌ DELETE TEAM (FIXED)
  ////////////////////////////////////////////////////////////
  Future<void> deleteTeam(dynamic team) async {
    HapticFeedback.mediumImpact();

    try {
      await ApiService.deleteTeam(team["team_id"]); // ✅ FIXED

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team deleted")),
      );

      loadTeams();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }

  void confirmDelete(team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Team"),
        content: Text("Remove ${team["team_name"]}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
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

  bool isFull() => teams.length >= widget.maxTeams;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.maxTeams - teams.length;
    final progress =
        widget.maxTeams == 0 ? 0.0 : teams.length / widget.maxTeams;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isFull() ? null : () {},
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          ////////////////////////////////////////////////////////////
          /// 🔥 HEADER
          ////////////////////////////////////////////////////////////
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF2C5364),
                  Color(0xFF00c6ff),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tournament Teams",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${teams.length}/${widget.maxTeams}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 8),
                Text(
                  isFull()
                      ? "All teams added ✅"
                      : "$remaining more teams needed",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          ////////////////////////////////////////////////////////////
          /// 🔥 BODY
          ////////////////////////////////////////////////////////////
          Expanded(
            child: isLoading
                ? _buildLoading()
                : teams.isEmpty
                    ? _buildEmpty()
                    // : ListView.builder(
                    //     itemCount: teams.length,
                    //     itemBuilder: (_, i) =>
                    //         _buildTeamCard(teams[i], i),
                    //   ),
                    : ListView(
  children: _groupTeams().entries.map((entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 GROUP HEADER
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            entry.key,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        /// TEAMS (UNCHANGED CARD)
        ...entry.value.map((t) =>
            _buildTeamCard(t, 0)).toList(),
      ],
    );
  }).toList(),
)
          ),
        ],
      ),
    );
  }


Map<String, List> _groupTeams() {
  Map<String, List> grouped = {};

  for (var t in teams) {
    final g = t["group_name"] ?? "No Group";

    if (!grouped.containsKey(g)) {
      grouped[g] = [];
    }

    grouped[g]!.add(t);
  }

  return grouped;
}
  ////////////////////////////////////////////////////////////
  /// 🧱 TEAM CARD (FIXED)
  ////////////////////////////////////////////////////////////
  Widget _buildTeamCard(dynamic t, int i) {
    final teamId = t["team_id"] ?? 0; // ✅ FIXED
    final name = t["team_name"] ?? "Unknown";
    final players = t["player_count"] ?? 0;
    final isReady = players >= 11;

    return Dismissible(
      key: Key(teamId.toString()), // ✅ FIXED
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        confirmDelete(t);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamSquadScreen(
                teamId: teamId, // ✅ FIXED
                teamName: name,
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
                isReady ? Colors.green.shade50 : Colors.orange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.05),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  name.isNotEmpty ? name[0] : "?",
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
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$players players",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReady
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isReady ? "READY" : "INCOMPLETE",
                  style: TextStyle(
                    color: isReady ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// EMPTY
  ////////////////////////////////////////////////////////////
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("No Teams Yet"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Add Team"),
          )
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// LOADING
  ////////////////////////////////////////////////////////////
  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.all(10),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}



