import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PlayingXIScreen extends StatefulWidget {
  final int matchId;
  final int teamId;

  const PlayingXIScreen({
    super.key,
    required this.matchId,
    required this.teamId,
  });

  @override
  State<PlayingXIScreen> createState() => _PlayingXIScreenState();
}

class _PlayingXIScreenState extends State<PlayingXIScreen> {
  List players = [];
  List selected = [];

  int? captainId;
  int? viceCaptainId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  ////////////////////////////////////////////////////////////
  /// LOAD TEAM PLAYERS
  ////////////////////////////////////////////////////////////
  Future<void> loadPlayers() async {
    try {
      final res = await ApiService.getTeamPlayers(widget.teamId);

      if (!mounted) return;

      setState(() {
        players = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  ////////////////////////////////////////////////////////////
  /// SELECT PLAYER
  ////////////////////////////////////////////////////////////
  void togglePlayer(int playerId) {
    setState(() {
      if (selected.contains(playerId)) {
        selected.remove(playerId);

        if (captainId == playerId) captainId = null;
        if (viceCaptainId == playerId) viceCaptainId = null;

      } else {
        if (selected.length >= 11) return;

        selected.add(playerId);
      }
    });
  }

  ////////////////////////////////////////////////////////////
  /// SET CAPTAIN
  ////////////////////////////////////////////////////////////
  void setCaptain(int playerId) {
    setState(() {
      captainId = playerId;
    });
  }

  ////////////////////////////////////////////////////////////
  /// SET VICE CAPTAIN
  ////////////////////////////////////////////////////////////
  void setViceCaptain(int playerId) {
    setState(() {
      viceCaptainId = playerId;
    });
  }

  ////////////////////////////////////////////////////////////
  /// SUBMIT XI
  ////////////////////////////////////////////////////////////
  Future<void> submitXI() async {
    if (selected.length != 11) {
      showError("Select exactly 11 players");
      return;
    }

    try {
      await ApiService.setPlayingXI(
        matchId: widget.matchId,
        teamId: widget.teamId,
        playerIds: selected,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showError("Failed to save XI");
    }
  }

  ////////////////////////////////////////////////////////////
  /// ERROR
  ////////////////////////////////////////////////////////////
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  ////////////////////////////////////////////////////////////
  /// PLAYER TILE
  ////////////////////////////////////////////////////////////
  Widget buildPlayer(dynamic p) {
    final id = p["id"];
    final name = p["name"];

    final isSelected = selected.contains(id);
    final isCaptain = captainId == id;
    final isVice = viceCaptainId == id;

    return GestureDetector(
      onTap: () => togglePlayer(id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(name[0]),
            ),
            const SizedBox(width: 12),

            Expanded(child: Text(name)),

            if (isSelected)
              Row(
                children: [
                  if (isCaptain)
                    const Chip(label: Text("C"), backgroundColor: Colors.green),

                  if (isVice)
                    const Chip(label: Text("VC"), backgroundColor: Colors.blue),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "C") setCaptain(id);
                      if (value == "VC") setViceCaptain(id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: "C", child: Text("Captain")),
                      const PopupMenuItem(value: "VC", child: Text("Vice Captain")),
                    ],
                  )
                ],
              )
          ],
        ),
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
        title: const Text("Select Playing XI"),
      ),
      body: Column(
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected: ${selected.length}/11",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: selected.length == 11 ? submitXI : null,
                  child: const Text("Confirm XI"),
                )
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (_, i) => buildPlayer(players[i]),
                  ),
          )
        ],
      ),
    );
  }
}