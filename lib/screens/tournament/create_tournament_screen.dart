import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateTournamentScreen extends StatefulWidget {
  @override
  _CreateTournamentScreenState createState() =>
      _CreateTournamentScreenState();
}

class _CreateTournamentScreenState
    extends State<CreateTournamentScreen> {

  final name = TextEditingController();
  final city = TextEditingController();
  final ground = TextEditingController();

  final orgName = TextEditingController();
  final orgPhone = TextEditingController();
  final orgEmail = TextEditingController();

  final teams = TextEditingController();

  // ✅ NEW
  String format = "league";
  int overs = 20;

  String category = "Local";
  String ballType = "Tennis";
  String pitchType = "Turf";
  String matchType = "T20";

  DateTime? startDate;
  DateTime? endDate;

  Future pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void create() async {
    if (name.text.isEmpty ||
        city.text.isEmpty ||
        teams.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    try {
      await ApiService.createTournamentFull(
        name: name.text,
        city: city.text,
        ground: ground.text,
        organizerName: orgName.text,
        organizerPhone: orgPhone.text,
        organizerEmail: orgEmail.text,
        startDate: startDate.toString(),
        endDate: endDate.toString(),
        category: category,
        ballType: ballType,
        pitchType: pitchType,
        matchType: matchType,
        totalTeams: int.tryParse(teams.text) ?? 0,

        // ✅ NEW
        format: format,
        overs: overs,
      );

      Navigator.pop(context);

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create tournament")),
      );
    }
  }

  Widget chip(String label, String selected, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == label,
      onSelected: (_) => setState(() => onSelect(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Tournament")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🏆 BASIC INFO
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Tournament Name"),
            ),
            TextField(
              controller: city,
              decoration: const InputDecoration(labelText: "City"),
            ),
            TextField(
              controller: ground,
              decoration: const InputDecoration(labelText: "Ground"),
            ),

            const Divider(),

            /// 👤 ORGANIZER
            TextField(
              controller: orgName,
              decoration: const InputDecoration(labelText: "Organizer Name"),
            ),
            TextField(
              controller: orgPhone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: orgEmail,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const Divider(),

            /// 📅 DATES
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => pickDate(true),
                  child: Text(startDate == null
                      ? "Start Date"
                      : startDate.toString().split(" ")[0]),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => pickDate(false),
                  child: Text(endDate == null
                      ? "End Date"
                      : endDate.toString().split(" ")[0]),
                ),
              ],
            ),

            const Divider(),

            /// 🔥 FORMAT (NEW)
            const Text("Format", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ["league", "knockout", "hybrid"]
                  .map((e) => chip(e, format, (v) => format = v))
                  .toList(),
            ),

            const SizedBox(height: 10),

            /// 🔢 OVERS (NEW)
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Overs"),
              onChanged: (v) => overs = int.tryParse(v) ?? 20,
            ),

            const Divider(),

            /// 🎯 CATEGORY
            Wrap(
              spacing: 8,
              children: ["Local", "Corporate", "College"]
                  .map((e) => chip(e, category, (v) => category = v))
                  .toList(),
            ),

            /// ⚾ BALL TYPE
            Wrap(
              spacing: 8,
              children: ["Tennis", "Leather"]
                  .map((e) => chip(e, ballType, (v) => ballType = v))
                  .toList(),
            ),

            /// 🏟️ PITCH
            Wrap(
              spacing: 8,
              children: ["Turf", "Matting"]
                  .map((e) => chip(e, pitchType, (v) => pitchType = v))
                  .toList(),
            ),

            /// 🏏 MATCH TYPE
            Wrap(
              spacing: 8,
              children: ["T20", "100", "Test"]
                  .map((e) => chip(e, matchType, (v) => matchType = v))
                  .toList(),
            ),

            const SizedBox(height: 10),

            /// 👥 TOTAL TEAMS
            TextField(
              controller: teams,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Teams"),
            ),

            const SizedBox(height: 20),

            /// 🚀 CREATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: create,
                child: const Text("Create Tournament"),
              ),
            )
          ],
        ),
      ),
    );
  }
}