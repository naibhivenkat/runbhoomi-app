import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class GroupSetupScreen extends StatefulWidget {
  final int tournamentId;
  final int totalTeams;

  const GroupSetupScreen({
    super.key,
    required this.tournamentId,
    required this.totalTeams,
  });

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  int groupCount = 2;
  bool isLoading = false;

  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  int gap = 10;

  int get teamsPerGroup {
    return (widget.totalTeams / groupCount).ceil();
  }

  Future pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (picked != null && mounted) {
      setState(() => startTime = picked);
    }
  }

  String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  // 🔥 FIXED (SAFE VERSION)
  void generate() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      await ApiService.generateFixturesWithGroups(
        tournamentId: widget.tournamentId,
        groupCount: groupCount,
        startTime: formatTime(startTime),
        gap: gap,
      );

      if (!mounted) return;

      Navigator.pop(context);

      // ⚠️ DON'T call setState after pop

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fixtures Generated ✅")),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget groupOption(int count) {
    return ChoiceChip(
      label: Text("$count Groups"),
      selected: groupCount == count,
      onSelected: (_) {
        if (!mounted) return;
        setState(() => groupCount = count);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Groups")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Total Teams: ${widget.totalTeams}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("Select Number of Groups"),

            Wrap(
              spacing: 10,
              children: [
                groupOption(2),
                groupOption(3),
                groupOption(4),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 START TIME
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Start Time"),
              subtitle: Text(formatTime(startTime)),
              trailing: const Icon(Icons.access_time),
              onTap: pickTime,
            ),

            /// 🔥 GAP INPUT
            TextField(
              decoration: const InputDecoration(
                labelText: "Gap Between Matches (minutes)",
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => gap = int.tryParse(v) ?? 10,
            ),

            const SizedBox(height: 20),

            /// PREVIEW
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Each group ≈ $teamsPerGroup teams",
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : generate,
                child: Text(
                  isLoading ? "Generating..." : "Generate Fixtures",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
