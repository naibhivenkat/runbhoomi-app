// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';

// class CreateTournamentScreen extends StatefulWidget {
// @override
// _CreateTournamentScreenState createState() =>
// _CreateTournamentScreenState();
// }

// class _CreateTournamentScreenState
// extends State<CreateTournamentScreen> {

// final name = TextEditingController();
// final city = TextEditingController();
// final ground = TextEditingController();

// final orgName = TextEditingController();
// final orgPhone = TextEditingController();
// final orgEmail = TextEditingController();

// final teams = TextEditingController();

// String format = "league";
// int overs = 20;

// String category = "Local";
// String ballType = "Tennis";
// String pitchType = "Turf";
// String matchType = "T20";

// DateTime? startDate;
// DateTime? endDate;

// bool isCreating = false;

// Future pickDate(bool isStart) async {
// final picked = await showDatePicker(
// context: context,
// initialDate: DateTime.now(),
// firstDate: DateTime.now(),
// lastDate: DateTime(2100),
// );


// if (picked != null) {
//   setState(() {
//     if (isStart) {
//       startDate = picked;
//     } else {
//       endDate = picked;
//     }
//   });
// }


// }

// void create() async {
// if (name.text.isEmpty ||
// city.text.isEmpty ||
// teams.text.isEmpty ||
// startDate == null ||
// endDate == null) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text("Fill all required fields")),
// );
// return;
// }


// setState(() => isCreating = true);

// try {
//   await ApiService.createTournamentFull(
//     name: name.text,
//     city: city.text,
//     ground: ground.text,
//     organizerName: orgName.text,
//     organizerPhone: orgPhone.text,
//     organizerEmail: orgEmail.text,
//     startDate: startDate.toString(),
//     endDate: endDate.toString(),
//     category: category,
//     ballType: ballType,
//     pitchType: pitchType,
//     matchType: matchType,
//     totalTeams: int.tryParse(teams.text) ?? 0,
//     format: format,
//     overs: overs,
//   );

//   if (!mounted) return;

//   Navigator.pop(context);

//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Tournament Created ✅")),
//   );

// } catch (e) {
//   setState(() => isCreating = false);

//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Failed to create tournament")),
//   );
// }


// }

// Widget chip(String label, String selected, Function(String) onSelect) {
// return ChoiceChip(
// label: Text(label),
// selected: selected == label,
// onSelected: (_) => setState(() => onSelect(label)),
// );
// }

// String formatDescription() {
// if (format == "league") {
// return "All teams play each other. Groups auto-created if teams are high.";
// } else if (format == "knockout") {
// return "Direct elimination. Lose once and you're out.";
// } else {
// return "Group stage + knockout rounds (recommended).";
// }
// }

// String formatPreview() {
// final total = int.tryParse(teams.text) ?? 0;


// if (total == 0) return "Enter team count to preview";

// if (format == "league") {
//   if (total <= 6) return "$total teams → Full league";
//   return "$total teams → Groups → Top teams qualify";
// }

// if (format == "knockout") {
//   return "$total teams → Knockout bracket";
// }

// return "$total teams → Groups → Semi Finals → Final";


// }

// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(title: const Text("Create Tournament")),
// body: SingleChildScrollView(
// padding: const EdgeInsets.all(16),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [


//         /// 🏆 BASIC INFO
//         _sectionTitle("Basic Info"),
//         TextField(
//           controller: name,
//           decoration: const InputDecoration(labelText: "Tournament Name"),
//         ),
//         TextField(
//           controller: city,
//           decoration: const InputDecoration(labelText: "City"),
//         ),
//         TextField(
//           controller: ground,
//           decoration: const InputDecoration(labelText: "Ground"),
//         ),

//         const SizedBox(height: 20),

//         /// 👤 ORGANIZER
//         _sectionTitle("Organizer"),
//         TextField(
//           controller: orgName,
//           decoration: const InputDecoration(labelText: "Name"),
//         ),
//         TextField(
//           controller: orgPhone,
//           decoration: const InputDecoration(labelText: "Phone"),
//         ),
//         TextField(
//           controller: orgEmail,
//           decoration: const InputDecoration(labelText: "Email"),
//         ),

//         const SizedBox(height: 20),

//         /// 📅 DATES
//         _sectionTitle("Schedule"),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => pickDate(true),
//                 child: Text(startDate == null
//                     ? "Start Date"
//                     : startDate.toString().split(" ")[0]),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => pickDate(false),
//                 child: Text(endDate == null
//                     ? "End Date"
//                     : endDate.toString().split(" ")[0]),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 20),

//         /// 🔥 FORMAT
//         _sectionTitle("Format"),
//         Wrap(
//           spacing: 8,
//           children: ["league", "knockout", "hybrid"]
//               .map((e) => chip(e, format, (v) => format = v))
//               .toList(),
//         ),

//         const SizedBox(height: 8),

//         Text(
//           formatDescription(),
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),

//         const SizedBox(height: 10),

//         /// 🔢 OVERS
//         TextField(
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: "Overs"),
//           onChanged: (v) => overs = int.tryParse(v) ?? 20,
//         ),

//         const SizedBox(height: 20),

//         /// 👥 TEAMS
//         _sectionTitle("Teams"),
//         TextField(
//           controller: teams,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: "Total Teams"),
//           onChanged: (_) => setState(() {}),
//         ),

//         const SizedBox(height: 10),

//         /// 🔍 PREVIEW
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             "📊 ${formatPreview()}",
//             style: const TextStyle(fontSize: 13),
//           ),
//         ),

//         const SizedBox(height: 20),

//         /// 🎯 CATEGORY
//         _sectionTitle("Category"),
//         Wrap(
//           spacing: 8,
//           children: ["Local", "Corporate", "College"]
//               .map((e) => chip(e, category, (v) => category = v))
//               .toList(),
//         ),

//         const SizedBox(height: 10),

//         /// ⚾ BALL TYPE
//         _sectionTitle("Ball Type"),
//         Wrap(
//           spacing: 8,
//           children: ["Tennis", "Leather"]
//               .map((e) => chip(e, ballType, (v) => ballType = v))
//               .toList(),
//         ),

//         const SizedBox(height: 10),

//         /// 🏟️ PITCH
//         _sectionTitle("Pitch"),
//         Wrap(
//           spacing: 8,
//           children: ["Turf", "Matting"]
//               .map((e) => chip(e, pitchType, (v) => pitchType = v))
//               .toList(),
//         ),

//         const SizedBox(height: 10),

//         /// 🏏 MATCH TYPE
//         _sectionTitle("Match Type"),
//         Wrap(
//           spacing: 8,
//           children: ["T20", "100", "Test"]
//               .map((e) => chip(e, matchType, (v) => matchType = v))
//               .toList(),
//         ),

//         const SizedBox(height: 30),

//         /// 🚀 CREATE BUTTON
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: isCreating ? null : create,
//             child: Text(
//               isCreating ? "Creating..." : "Create Tournament",
//             ),
//           ),
//         ),

//         const SizedBox(height: 10),

//         const Text(
//           "Next: Add teams → Generate fixtures → Start matches",
//           style: TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     ),
//   ),
// );


// }

// Widget _sectionTitle(String text) {
// return Padding(
// padding: const EdgeInsets.only(bottom: 8),
// child: Text(
// text,
// style: const TextStyle(
// fontWeight: FontWeight.bold, fontSize: 16),
// ),
// );
// }
// }










import 'dart:convert';
import 'package:flutter/material.dart';
import '../../main.dart'; // To access the global 'isar' variable
import '../../models/tournament_model.dart';
import '../../models/sync_action_model.dart';

class CreateTournamentScreen extends StatefulWidget {
  @override
  _CreateTournamentScreenState createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final name = TextEditingController();
  final city = TextEditingController();
  final ground = TextEditingController();
  final orgName = TextEditingController();
  final orgPhone = TextEditingController();
  final orgEmail = TextEditingController();
  final teams = TextEditingController();

  String format = "league";
  int overs = 20;
  String category = "Local";
  String ballType = "Tennis";
  String pitchType = "Turf";
  String matchType = "T20";

  DateTime? startDate;
  DateTime? endDate;

  bool isCreating = false;

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
    if (name.text.isEmpty || city.text.isEmpty || teams.text.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      // 1. CREATE LOCAL TOURNAMENT MODEL
      final localTournament = Tournament()
        ..name = name.text
        ..location = city.text
        ..type = matchType
        ..totalTeams = int.tryParse(teams.text) ?? 0
        ..startDate = startDate.toString()
        ..endDate = endDate.toString();

      // 2. CREATE THE API PAYLOAD FOR THE BACKGROUND QUEUE
      // This payload perfectly matches what your FastAPI server expects
      final payloadData = {
        "id": localTournament.backendId, // Sending the generated UUID!
        "name": name.text,
        "city": city.text,
        "ground": ground.text,
        "organizer_name": orgName.text,
        "organizer_phone": orgPhone.text,
        "organizer_email": orgEmail.text,
        "start_date": startDate.toString(),
        "end_date": endDate.toString(),
        "category": category,
        "ball_type": ballType,
        "pitch_type": pitchType,
        "match_type": matchType,
        "total_teams": int.tryParse(teams.text) ?? 0,
        "format": format,
        "overs": overs,
      };

      final syncAction = SyncAction()
        ..method = 'POST'
        ..endpoint = '/tournaments/create'
        ..payload = jsonEncode(payloadData);

      // 3. SAVE BOTH TO LOCAL DATABASE INSTANTLY (Offline-First Magic)
      await isar.writeTxn(() async {
        await isar.tournaments.put(localTournament);
        await isar.syncActions.put(syncAction);
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tournament Created Locally ✅")),
      );
    } catch (e) {
      setState(() => isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save tournament: $e")),
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

  String formatDescription() {
    if (format == "league") {
      return "All teams play each other. Groups auto-created if teams are high.";
    } else if (format == "knockout") {
      return "Direct elimination. Lose once and you're out.";
    } else {
      return "Group stage + knockout rounds (recommended).";
    }
  }

  String formatPreview() {
    final total = int.tryParse(teams.text) ?? 0;
    if (total == 0) return "Enter team count to preview";
    if (format == "league") {
      if (total <= 6) return "$total teams → Full league";
      return "$total teams → Groups → Top teams qualify";
    }
    if (format == "knockout") {
      return "$total teams → Knockout bracket";
    }
    return "$total teams → Groups → Semi Finals → Final";
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
            _sectionTitle("Basic Info"),
            TextField(controller: name, decoration: const InputDecoration(labelText: "Tournament Name")),
            TextField(controller: city, decoration: const InputDecoration(labelText: "City")),
            TextField(controller: ground, decoration: const InputDecoration(labelText: "Ground")),
            const SizedBox(height: 20),

            _sectionTitle("Organizer"),
            TextField(controller: orgName, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: orgPhone, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: orgEmail, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 20),

            _sectionTitle("Schedule"),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => pickDate(true), child: Text(startDate == null ? "Start Date" : startDate.toString().split(" ")[0]))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () => pickDate(false), child: Text(endDate == null ? "End Date" : endDate.toString().split(" ")[0]))),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle("Format"),
            Wrap(spacing: 8, children: ["league", "knockout", "hybrid"].map((e) => chip(e, format, (v) => format = v)).toList()),
            const SizedBox(height: 8),
            Text(formatDescription(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),

            TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Overs"), onChanged: (v) => overs = int.tryParse(v) ?? 20),
            const SizedBox(height: 20),

            _sectionTitle("Teams"),
            TextField(controller: teams, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Total Teams"), onChanged: (_) => setState(() {})),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: Text("📊 ${formatPreview()}", style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 20),

            _sectionTitle("Category"),
            Wrap(spacing: 8, children: ["Local", "Corporate", "College"].map((e) => chip(e, category, (v) => category = v)).toList()),
            const SizedBox(height: 10),

            _sectionTitle("Ball Type"),
            Wrap(spacing: 8, children: ["Tennis", "Leather"].map((e) => chip(e, ballType, (v) => ballType = v)).toList()),
            const SizedBox(height: 10),

            _sectionTitle("Pitch"),
            Wrap(spacing: 8, children: ["Turf", "Matting"].map((e) => chip(e, pitchType, (v) => pitchType = v)).toList()),
            const SizedBox(height: 10),

            _sectionTitle("Match Type"),
            Wrap(spacing: 8, children: ["T20", "100", "Test"].map((e) => chip(e, matchType, (v) => matchType = v)).toList()),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCreating ? null : create,
                child: Text(isCreating ? "Creating..." : "Create Tournament"),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Next: Add teams → Generate fixtures → Start matches", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}