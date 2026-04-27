import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'scoring_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  final int matchId;
  final int teamAId;
  final int teamBId;
  final String teamAName;
  final String teamBName;
  final int tournamentId;

  const MatchSetupScreen({
    super.key,
    required this.matchId,
    required this.teamAId,
    required this.teamBId,
    required this.teamAName,
    required this.teamBName,
    required this.tournamentId,
  });

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  List playersA = [];
  List playersB = [];

  List battingPlayers = [];
  List bowlingPlayers = [];

  int? strikerId;
  int? nonStrikerId;

  String? tossWinner;
  String? tossDecision;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  Future loadPlayers() async {
    final a = await ApiService.getTeamPlayers(widget.teamAId);
    final b = await ApiService.getTeamPlayers(widget.teamBId);

    if (!mounted) return;

    setState(() {
      playersA = a;
      playersB = b;
      loading = false;
    });
  }

  void applyTossLogic() {
    if (tossWinner == null || tossDecision == null) return;

    bool isA = tossWinner == "A";

    bool batFirst =
        (isA && tossDecision == "bat") ||
        (!isA && tossDecision == "bowl");

    setState(() {
      battingPlayers = batFirst
          ? (isA ? playersA : playersB)
          : (isA ? playersB : playersA);

      bowlingPlayers = batFirst
          ? (isA ? playersB : playersA)
          : (isA ? playersA : playersB);

      strikerId = null;
      nonStrikerId = null;
    });
  }

  Future startMatch() async {
    if (strikerId == null || nonStrikerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select openers")),
      );
      return;
    }

    await ApiService.startMatch(
      widget.matchId,
      strikerId!,
      nonStrikerId!,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScoringScreen(matchId: widget.matchId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(title: const Text("Match Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 TEAMS HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _team(widget.teamAName),
                  const Text("VS",
                      style: TextStyle(color: Colors.white)),
                  _team(widget.teamBName),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🪙 TOSS
            _sectionTitle("Toss"),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Toss Winner",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: "A", child: Text(widget.teamAName)),
                DropdownMenuItem(
                    value: "B", child: Text(widget.teamBName)),
              ],
              onChanged: (v) {
                tossWinner = v;
                applyTossLogic();
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Decision",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "bat", child: Text("Bat")),
                DropdownMenuItem(value: "bowl", child: Text("Bowl")),
              ],
              onChanged: (v) {
                tossDecision = v;
                applyTossLogic();
              },
            ),

            const SizedBox(height: 20),

            /// 🏏 OPENERS
            if (battingPlayers.isNotEmpty) ...[
              _sectionTitle("Select Openers"),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Striker",
                  border: OutlineInputBorder(),
                ),
                items: battingPlayers.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem(
                    value: p["id"],
                    child: Text(p["name"]),
                  );
                }).toList(),
                onChanged: (v) => strikerId = v,
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Non-Striker",
                  border: OutlineInputBorder(),
                ),
                items: battingPlayers.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem(
                    value: p["id"],
                    child: Text(p["name"]),
                  );
                }).toList(),
                onChanged: (v) => nonStrikerId = v,
              ),
            ],

            const Spacer(),

            /// 🚀 START BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
                onPressed: startMatch,
                child: const Text(
                  "Start Match",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _team(String name) {
    return Column(
      children: [
        CircleAvatar(radius: 20, child: Text(name[0])),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import '../tournament/group_setup_screen.dart';
// import 'match_setup_screen.dart';

// enum SortType { time, group, teams, status }

// class MatchesTab extends StatefulWidget {
//   final int tournamentId;
//   final String role;

//   const MatchesTab({
//     super.key,
//     required this.tournamentId,
//     required this.role,
//   });

//   @override
//   State<MatchesTab> createState() => _MatchesTabState();
// }

// class _MatchesTabState extends State<MatchesTab> {
//   bool _disposed = false;
//   List matches = [];
//   bool isLoading = true;
//   bool isGenerating = false;

//   bool hasLive = false;
//   bool hasCompleted = false;
//   bool hasUpcoming = false;

//   Map<int, String> groupNames = {};
//   SortType selectedSort = SortType.time;

//   final List<Color> groupColorPool = [
//     Colors.blue,
//     Colors.green,
//     Colors.orange,
//     Colors.purple,
//     Colors.red,
//     Colors.teal,
//     Colors.indigo,
//     Colors.brown,
//   ];

//   Color getGroupColor(String groupName) {
//     final index = groupName.hashCode % groupColorPool.length;
//     return groupColorPool[index.abs()];
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadMatches();
//   }

//   @override
// void dispose() {
//   _disposed = true;
//   super.dispose();
// }

//   Future<void> loadMatches() async {
//   try {
//     final data =
//         await ApiService.getTournamentMatches(widget.tournamentId);

//     if (!mounted || _disposed) return;

//     final groups =
//         await ApiService.getGroups(widget.tournamentId);

//     if (!mounted || _disposed) return;

//     bool live = false;
//     bool completed = false;
//     bool upcoming = false;

//     for (var m in data) {
//       if (m["is_live"] == true) live = true;
//       if (m["winner"] != null) completed = true;
//       if (m["winner"] == null && m["is_live"] != true) upcoming = true;
//     }

//     if (!mounted || _disposed) return;

//     setState(() {
//       matches = data;
//       isLoading = false;
//       hasLive = live;
//       hasCompleted = completed;
//       hasUpcoming = upcoming;

//       groupNames = {
//         for (var g in groups) g["id"]: g["name"]
//       };
//     });

//   } catch (e) {
//     if (!mounted || _disposed) return;
//     setState(() => isLoading = false);
//   }
// }

//   Future<void> generateFixtures() async {
//     if (isGenerating) return;

//     if (hasLive || hasCompleted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Tournament already started")),
//       );
//       return;
//     }

//     if (!mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => GroupSetupScreen(
//           tournamentId: widget.tournamentId,
//           totalTeams: matches.length,
//         ),
//       ),
//     );
//   }

//   Future<void> openMatchSetup(Map m) async {
//     final res = await ApiService.initMatchFromFixture(m["id"]);
//     final matchId = res["match_id"];

//     if (matchId == null) return;

//     if (!mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MatchSetupScreen(
//           matchId: matchId,
//           teamAId: m["team_a_id"] ?? 0,
//           teamBId: m["team_b_id"] ?? 0,
//           teamAName: m["team_a"] ?? "Team A",
//           teamBName: m["team_b"] ?? "Team B",
//           tournamentId: widget.tournamentId,
//         ),
//       ),
//     );
//   }

//   String getStatus(Map m) {
//     if (m["winner"] != null) return "COMPLETED";
//     if (m["is_live"] == true) return "LIVE";
//     return "UPCOMING";
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case "LIVE":
//         return Colors.red;
//       case "COMPLETED":
//         return Colors.grey;
//       default:
//         return Colors.orange;
//     }
//   }

//   DateTime? parseTime(String? t) {
//     if (t == null) return null;
//     try {
//       final parts = t.split(":");
//       final now = DateTime.now();
//       return DateTime(
//         now.year,
//         now.month,
//         now.day,
//         int.parse(parts[0]),
//         int.parse(parts[1]),
//       );
//     } catch (_) {
//       return null;
//     }
//   }

//   String formatTime(String? time) {
//     if (time == null) return "Time TBD";
//     return time;
//   }

//   List getSortedMatchesByType() {
//     List list = List.from(matches);

//     switch (selectedSort) {
//       case SortType.time:
//         list.sort((a, b) {
//           final aLive = a["is_live"] == true;
//           final bLive = b["is_live"] == true;

//           if (aLive && !bLive) return -1;
//           if (!aLive && bLive) return 1;

//           final t1 = parseTime(a["match_time"]);
//           final t2 = parseTime(b["match_time"]);

//           if (t1 == null || t2 == null) return 0;
//           return t1.compareTo(t2);
//         });
//         break;

//       case SortType.group:
//         list.sort((a, b) {
//           final g1 = groupNames[a["group_id"]] ?? "";
//           final g2 = groupNames[b["group_id"]] ?? "";

//           final groupCompare = g1.compareTo(g2);
//           if (groupCompare != 0) return groupCompare;

//           final t1 = parseTime(a["match_time"]);
//           final t2 = parseTime(b["match_time"]);

//           if (t1 == null || t2 == null) return 0;
//           return t1.compareTo(t2);
//         });
//         break;

//       case SortType.teams:
//         list.sort((a, b) {
//           final t1 = (a["team_a"] ?? "") + (a["team_b"] ?? "");
//           final t2 = (b["team_a"] ?? "") + (b["team_b"] ?? "");
//           return t1.compareTo(t2);
//         });
//         break;

//       case SortType.status:
//         list.sort((a, b) {
//           int rank(String s) {
//             if (s == "LIVE") return 0;
//             if (s == "UPCOMING") return 1;
//             return 2;
//           }

//           return rank(getStatus(a)).compareTo(rank(getStatus(b)));
//         });
//         break;
//     }

//     return list;
//   }

//   Map<String, List<Map>> groupMatches(List matches) {
//     final Map<String, List<Map>> grouped = {};

//     for (var m in matches) {
//       final groupName = m["group_id"] == null
//           ? "League"
//           : groupNames[m["group_id"]] ?? "Group";

//       grouped.putIfAbsent(groupName, () => []);
//       grouped[groupName]!.add(m);
//     }

//     return grouped;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sorted = getSortedMatchesByType();

//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (matches.isEmpty) {
//       return Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: _buildControls(),
//           ),
//           const Expanded(
//             child: Center(child: Text("No Fixtures")),
//           ),
//         ],
//       );
//     }

  
//     return CustomScrollView(
//   physics: const BouncingScrollPhysics(),
//   slivers: [

//     /// 🔘 CONTROLS
//     SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//         child: _buildControls(),
//       ),
//     ),

//     /// 🔽 STICKY SORT BAR (FIXED BACKGROUND)
//     SliverPersistentHeader(
//       pinned: true,
//       delegate: _StickyHeader(
//         child: Container(
//           color: Colors.white, // ✅ important fix
//           child: _buildSortBar(),
//         ),
//       ),
//     ),

//     /// 🔥 TOP SPACING FIX (VERY IMPORTANT)
//     const SliverToBoxAdapter(
//       child: SizedBox(height: 10),
//     ),

//     /// 📋 MATCH LIST
//     SliverPadding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 80), // ✅ bottom space added
//       sliver: selectedSort == SortType.group
//           ? _buildGroupedList(sorted)
//           : _buildNormalList(sorted),
//     ),
//   ],
// );
//   }

//   Widget _buildGroupedList(List sorted) {
//     final grouped = groupMatches(sorted);
//     final groups = grouped.keys.toList()..sort();

//     return SliverList(
//       delegate: SliverChildListDelegate(
//         groups.expand((group) {
//           final color = getGroupColor(group);

//           return [
//             Padding(
//               padding: const EdgeInsets.only(top: 14, bottom: 6),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       group,
//                       style: TextStyle(
//                         color: color,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     "${grouped[group]!.length} matches",
//                     style: const TextStyle(
//                         fontSize: 11, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             ...grouped[group]!.map((m) => _buildMatch(m, 0)),
//           ];
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildNormalList(List sorted) {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) => _buildMatch(sorted[index], index),
//         childCount: sorted.length,
//       ),
//     );
//   }

//   Widget _buildSortBar() {
//     return Container(
//       height: 50,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       color: const Color(0xFFF5F6FA),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.sort, size: 18),
//               const SizedBox(width: 4),
//               Text(selectedSort.name.toUpperCase()),
//             ],
//           ),
//           const SizedBox(width: 6),
//           PopupMenuButton<SortType>(
//             onSelected: (value) {
//                 if (!mounted || _disposed) return;
//               setState(() => selectedSort = value);
//             },
//             itemBuilder: (context) {
//               return SortType.values.map((type) {
//                 return PopupMenuItem(
//                   value: type,
//                   child: Text(type.name),
//                 );
//               }).toList();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControls() {
//     if (widget.role != "ADMIN") return const SizedBox();

//     return ElevatedButton.icon(
//       onPressed: generateFixtures,
//       icon: const Icon(Icons.sync),
//       label: Text(matches.isEmpty
//           ? "Generate Fixtures"
//           : "Reset Fixtures"),
//     );
//   }

//  Widget _buildMatch(Map m, int index) {
//   final status = getStatus(m);
//   final groupName = m["group_id"] == null
//       ? "League"
//       : groupNames[m["group_id"]] ?? "Group";

//   final color = getGroupColor(groupName);
//   final isLive = status == "LIVE";

//   return InkWell(
//     borderRadius: BorderRadius.circular(16),
//     onTap: () => openMatchSetup(m),
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   groupName,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               Row(
//                 children: [
//                   if (isLive)
//                     Container( // ✅ FIXED (no animation)
//                       width: 6,
//                       height: 6,
//                       margin: const EdgeInsets.only(right: 6),
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                     ),

//                   Text(
//                     status,
//                     style: TextStyle(
//                       color: getStatusColor(status),
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           Text(
//             "Match #${m["id"]}",
//             style: const TextStyle(fontWeight: FontWeight.w700),
//           ),

//           const SizedBox(height: 10),

//           Row(
//             children: [
//               Expanded(child: Text(m["team_a"])),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Text("VS", style: TextStyle(fontSize: 10)),
//               ),
//               Expanded(
//                 child: Text(
//                   m["team_b"],
//                   textAlign: TextAlign.end,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               const Icon(Icons.schedule, size: 14),
//               const SizedBox(width: 4),
//               Text(formatTime(m["match_time"])),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }

// class _StickyHeader extends SliverPersistentHeaderDelegate {
//   final Widget child;

//   _StickyHeader({required this.child});

//   @override
//   double get minExtent => 50;

//   @override
//   double get maxExtent => 50;

//   @override
//   Widget build(context, shrinkOffset, overlapsContent) {
//     return child;
//   }

//   @override
// bool shouldRebuild(covariant _StickyHeader oldDelegate) => false;
// }



// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import 'match_detail_screen.dart';
// import 'scoring_screen.dart';

// class MatchSetupScreen extends StatefulWidget {
//   final int matchId;
//   final int teamAId;
//   final int teamBId;
//   final String teamAName;
//   final String teamBName;
//   final int tournamentId;

//   const MatchSetupScreen({
//     super.key,
//     required this.matchId,
//     required this.teamAId,
//     required this.teamBId,
//     required this.teamAName,
//     required this.teamBName,
//     required this.tournamentId,
//   });

//   @override
//   State<MatchSetupScreen> createState() => _MatchSetupScreenState();
// }

// class _MatchSetupScreenState extends State<MatchSetupScreen> {
//   List playersA = [];
//   List playersB = [];

//   List battingPlayers = [];
//   List bowlingPlayers = [];

//   int? strikerId;
//   int? nonStrikerId;

//   String? tossWinner; // "A" or "B"
//   String? tossDecision; // "bat" or "bowl"

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadPlayers();
//   }

//   Future loadPlayers() async {
//     try {
//       final a = await ApiService.getTeamPlayers(widget.teamAId);
//       final b = await ApiService.getTeamPlayers(widget.teamBId);

//       if (!mounted) return;

//       setState(() {
//         playersA = a;
//         playersB = b;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   void applyTossLogic() {
//     if (tossWinner == null || tossDecision == null) return;

//     bool isAWinning = tossWinner == "A";

//     bool batFirst =
//         (isAWinning && tossDecision == "bat") ||
//         (!isAWinning && tossDecision == "bowl");

//     setState(() {
//       if (batFirst) {
//         battingPlayers = isAWinning ? playersA : playersB;
//         bowlingPlayers = isAWinning ? playersB : playersA;
//       } else {
//         battingPlayers = isAWinning ? playersB : playersA;
//         bowlingPlayers = isAWinning ? playersA : playersB;
//       }

//       strikerId = null;
//       nonStrikerId = null;
//     });
//   }

//   // ✅ FILTER BOTH SIDES
//   List getStrikerList() {
//     return battingPlayers
//         .where((p) => p["id"] != nonStrikerId)
//         .toList();
//   }

//   List getNonStrikerList() {
//     return battingPlayers
//         .where((p) => p["id"] != strikerId)
//         .toList();
//   }

//   Future startMatch() async {
//   if (strikerId == null || nonStrikerId == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Select opening batsmen")),
//     );
//     return;
//   }

//   try {
//     await ApiService.startMatch(
//       widget.matchId,
//       strikerId!,
//       nonStrikerId!,
//     );

//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ScoringScreen(matchId: widget.matchId),
//       ),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Failed to start match")),
//     );
//   }
// }

//   Widget playerDropdown(
//       String label, List players, Function(int) onSelect) {
//     return DropdownButtonFormField<int>(
//       value: null,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       items: players.map<DropdownMenuItem<int>>((p) {
//         return DropdownMenuItem(
//           value: p["id"],
//           child: Text(p["name"]),
//         );
//       }).toList(),
//       onChanged: (v) {
//         if (v != null) onSelect(v);
//       },
//     );
//   }

//   Widget tossSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Toss",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 10),

//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             labelText: "Toss Winner",
//             border: OutlineInputBorder(),
//           ),
//           items: [
//             DropdownMenuItem(
//                 value: "A", child: Text(widget.teamAName)),
//             DropdownMenuItem(
//                 value: "B", child: Text(widget.teamBName)),
//           ],
//           onChanged: (v) {
//             tossWinner = v;
//             applyTossLogic();
//           },
//         ),

//         const SizedBox(height: 12),

//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             labelText: "Decision",
//             border: OutlineInputBorder(),
//           ),
//           items: const [
//             DropdownMenuItem(value: "bat", child: Text("Bat")),
//             DropdownMenuItem(value: "bowl", child: Text("Bowl")),
//           ],
//           onChanged: (v) {
//             tossDecision = v;
//             applyTossLogic();
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Match Setup")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "${widget.teamAName} vs ${widget.teamBName}",
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 18),
//             ),

//             const SizedBox(height: 20),

//             // 🪙 Toss
//             tossSection(),

//             const SizedBox(height: 20),

//             if (battingPlayers.isNotEmpty) ...[
//               const Text("Batting Setup",
//                   style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

//               const SizedBox(height: 12),

//               // 🏏 STRIKER
//               playerDropdown("Striker", getStrikerList(), (v) {
//                 strikerId = v;

//                 // reset if conflict
//                 if (nonStrikerId == v) {
//                   nonStrikerId = null;
//                 }

//                 setState(() {});
//               }),

//               const SizedBox(height: 12),

//               // 🏏 NON-STRIKER
//               playerDropdown("Non-Striker", getNonStrikerList(), (v) {
//                 nonStrikerId = v;

//                 // reset if conflict
//                 if (strikerId == v) {
//                   strikerId = null;
//                 }

//                 setState(() {});
//               }),
//             ],

//             const SizedBox(height: 30),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: startMatch,
//                 child: const Text("Start Match"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }