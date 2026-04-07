import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddPlayerScreen extends StatefulWidget {
  final int teamId;

  const AddPlayerScreen({super.key, required this.teamId});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final name = TextEditingController();

  void addPlayer() async {
    if (name.text.isEmpty) return;

    try {
      // ⚠️ TEMP: create dummy player (you can improve later)
      final playerId = DateTime.now().millisecondsSinceEpoch % 100000;

      await ApiService.addPlayerToTeam(widget.teamId, playerId);

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Player")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Player Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addPlayer,
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}