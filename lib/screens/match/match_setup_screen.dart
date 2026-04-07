import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'match_detail_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  final int matchId;

  // ✅ FIX: use IDs + names
  final int teamAId;
  final int teamBId;
  final String teamAName;
  final String teamBName;

  const MatchSetupScreen({
    super.key,
    required this.matchId,
    required this.teamAId,
    required this.teamBId,
    required this.teamAName,
    required this.teamBName,
  });

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  List playersA = [];
  List playersB = [];

  int? strikerId;
  int? nonStrikerId;
  String bowlerName = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  // ✅ FIX: use team IDs
  Future loadPlayers() async {
    try {
      final a = await ApiService.getTeamPlayers(widget.teamAId);
      final b = await ApiService.getTeamPlayers(widget.teamBId);

      if (!mounted) return;

      setState(() {
        playersA = a;
        playersB = b;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      debugPrint("Error loading players: $e");
    }
  }

  Future startMatch() async {
    // ✅ VALIDATION
    if (strikerId == null ||
        nonStrikerId == null ||
        bowlerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select all fields")),
      );
      return;
    }

    if (strikerId == nonStrikerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Striker and Non-Striker must be different")),
      );
      return;
    }

    try {
      await ApiService.startMatch(
        widget.matchId,
        strikerId!,
        nonStrikerId!,
        bowlerName,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(matchId: widget.matchId),
        ),
      );
    } catch (e) {
      debugPrint("Start match error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start match")),
      );
    }
  }

  Widget playerDropdown(
      String label, List players, Function(int) onSelect) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: players.map<DropdownMenuItem<int>>((p) {
        return DropdownMenuItem(
          value: p["id"],
          child: Text(p["name"]),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onSelect(v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Match Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ TEAM NAMES
            Text(
              "${widget.teamAName} vs ${widget.teamBName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            // 🏏 STRIKER
            playerDropdown(
              "Striker",
              playersA,
              (v) => strikerId = v,
            ),

            const SizedBox(height: 12),

            // 🏏 NON-STRIKER
            playerDropdown(
              "Non-Striker",
              playersA,
              (v) => nonStrikerId = v,
            ),

            const SizedBox(height: 12),

            // 🎯 BOWLER
            TextField(
              decoration: InputDecoration(
                labelText: "Bowler Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (v) => bowlerName = v,
            ),

            const SizedBox(height: 30),

            // 🚀 START MATCH
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startMatch,
                child: const Text("Start Match"),
              ),
            )
          ],
        ),
      ),
    );
  }
}