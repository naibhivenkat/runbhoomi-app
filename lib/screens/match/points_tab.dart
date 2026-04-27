import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class PointsTab extends StatefulWidget {
  final int tournamentId;

  const PointsTab({required this.tournamentId});

  @override
  State<PointsTab> createState() => _PointsTabState();
}

class _PointsTabState extends State<PointsTab> {
  List<Map<String, dynamic>> points = [];

  bool isLoading = true;
  String? error;
  bool _disposed = false;

  int? expandedIndex;
  
@override
void dispose() {
  _disposed = true;
  super.dispose();
}
  @override
  void initState() {
    super.initState();
    loadPoints();
  }

 

  Future<void> loadPoints() async {
  try {
    final pointsRaw = await ApiService.getPoints(widget.tournamentId);
    final teamsRaw = await ApiService.getTeams(widget.tournamentId);
    final matchesRaw = await ApiService.getMatchesByTournament(widget.tournamentId);

    final pointsData = List<Map<String, dynamic>>.from(pointsRaw ?? []);
    final teamsData = List<Map<String, dynamic>>.from(teamsRaw ?? []);
    final matchesData = List<Map<String, dynamic>>.from(matchesRaw ?? []);

    final Map<int, String> teamGroupMap = {};
    for (var t in teamsData) {
      final id = t["team_id"];
      final group = (t["group"] ?? "A").toString();
      if (id != null) {
        teamGroupMap[id] = group;
      }
    }

    final Map<int, List<Map<String, dynamic>>> teamMatches = {};
    for (var m in matchesData) {
      final a = m["team_a_id"];
      final b = m["team_b_id"];

      if (a != null) {
        teamMatches.putIfAbsent(a, () => []).add(m);
      }
      if (b != null) {
        teamMatches.putIfAbsent(b, () => []).add(m);
      }
    }

    for (var p in pointsData) {
      final teamId = p["team_id"];
      p["group"] = teamGroupMap[teamId] ?? "A";
      p["matches"] = teamMatches[teamId] ?? [];
    }

    pointsData.sort((a, b) {
      final ptsA = (a["points"] ?? 0);
      final ptsB = (b["points"] ?? 0);

      if (ptsB != ptsA) return ptsB.compareTo(ptsA);

      final nrrA = ((a["nrr"] ?? 0) as num).toDouble();
      final nrrB = ((b["nrr"] ?? 0) as num).toDouble();

      return nrrB.compareTo(nrrA);
    });

    if (!mounted || _disposed) return;

    setState(() {
      points = pointsData;
      isLoading = false;
    });

  } catch (e) {
    if (!mounted || _disposed) return;

    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}

  /// GROUPING
  Map<String, List<Map<String, dynamic>>> groupPoints() {
    final map = <String, List<Map<String, dynamic>>>{};

    for (var p in points) {
      final g = p["group"] ?? "A";
      map.putIfAbsent(g, () => []).add(p);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (points.isEmpty) {
      return _empty();
    }

    final groups = groupPoints();

    return RefreshIndicator(
      onRefresh: loadPoints,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: groups.entries.map((entry) {
          return _buildGroup(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  /// ================= GROUP =================
  Widget _buildGroup(String group, List teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Group $group",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildHeader(),
        ...List.generate(teams.length, (i) {
          return _buildRow(teams[i], i);
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: const [
          SizedBox(width: 28, child: Text("#")),
          Expanded(flex: 3, child: Text("Team")),
          Expanded(child: Center(child: Text("P"))),
          Expanded(child: Center(child: Text("W"))),
          Expanded(child: Center(child: Text("L"))),
          Expanded(child: Center(child: Text("Pts"))),
          Expanded(child: Center(child: Text("NRR"))),
        ],
      ),
    );
  }

  /// ================= ROW =================
  Widget _buildRow(Map<String, dynamic> p, int index) {
    final isExpanded = expandedIndex == index;
    //final team = p["team"] ?? "-";
    final team = (p["team"] ?? "-").toString();

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              expandedIndex =
                  isExpanded ? null : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: index < 2
                  ? Colors.green.withOpacity(0.06)
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                    color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 28,
                    child: Text("${index + 1}")),

                /// TEAM
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text(team[0]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          team,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                    child: Center(
                        child: Text("${p["played"] ?? 0}"))),
                Expanded(
                    child: Center(
                        child: Text("${p["wins"] ?? 0}"))),
                Expanded(
                    child: Center(
                        child: Text("${p["losses"] ?? 0}"))),
                Expanded(
                    child: Center(
                        child: Text("${p["points"] ?? 0}"))),
                Expanded(
                  child: Center(
                    child: Text(
                      ((p["nrr"] ?? 0) as num)
                          .toDouble()
                          .toStringAsFixed(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isExpanded) _buildExpanded(p),
      ],
    );
  }

  /// ================= EXPANDED =================
  Widget _buildExpanded(Map<String, dynamic> p) {
    final matches = p["matches"] ?? [];

    final recent =
        matches.where((m) => m["result"] != null).toList();

    final upcoming =
        matches.where((m) => m["result"] == null).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.isNotEmpty) ...[
            const Text("Recent",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...recent.map<Widget>((m) {
              final res = m["result"] ?? "";
              final isWin = res.contains("Won");

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(m["opponent"] ?? "-")),
                    Text(
                      res,
                      style: TextStyle(
                          color: isWin
                              ? Colors.green
                              : Colors.red),
                    ),
                  ],
                ),
              );
            }),
          ],

          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text("Upcoming",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...upcoming.map<Widget>((m) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(m["opponent"] ?? "-")),
                    const Text("vs"),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Text("No points yet"),
    );
  }
}


