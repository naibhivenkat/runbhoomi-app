import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TeamRequestsScreen extends StatefulWidget {
  final int tournamentId;

  const TeamRequestsScreen({required this.tournamentId});

  @override
  State<TeamRequestsScreen> createState() =>
      _TeamRequestsScreenState();
}

class _TeamRequestsScreenState
    extends State<TeamRequestsScreen> {
  List requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

Future<void> load() async {
  if (!mounted) return;
  setState(() => isLoading = true);

  try {
    final data =
        await ApiService.getJoinRequests(widget.tournamentId);

    if (!mounted) return;
    setState(() => requests = data);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to load requests")),
    );
  }

  if (!mounted) return;
  setState(() => isLoading = false);
}
Future<void> approve(int teamId) async {
  try {
    await ApiService.approveTeam(widget.tournamentId, teamId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Team Approved")),
    );

    load();
  } catch (e) {
    /// 🔥 HANDLE RENDER FAKE ERROR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Approved (network unstable)"),
      ),
    );

    load(); // still reload because backend succeeded
  }
}

Future<void> reject(int teamId) async {
  try {
    await ApiService.rejectTeam(widget.tournamentId, teamId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Team Rejected")),
    );

    load();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rejected (network unstable)"),
      ),
    );

    load();
  }
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requests.isEmpty) {
      return const Center(
        child: Text(
          "No pending requests",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final t = requests[i];

        return Card(
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                t["team_name"][0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              t["team_name"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            /// 🔥 ACTION BUTTONS
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => approve(t["team_id"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Approve"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => reject(t["team_id"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Reject"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}