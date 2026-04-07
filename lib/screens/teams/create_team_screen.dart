import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateTeamScreen extends StatefulWidget {
  final int captainId;

  const CreateTeamScreen({required this.captainId});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final ctrl = TextEditingController();
  bool isLoading = false;

  void create() async {
    if (ctrl.text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.createTeam(
        ctrl.text.trim(),
        widget.captainId,
      );

      Navigator.pop(context, res["id"]); // return teamId
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create team")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Team")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: "Team Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : create,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create"),
            )
          ],
        ),
      ),
    );
  }
}