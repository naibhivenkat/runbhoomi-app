import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../tournament/group_setup_screen.dart';
import 'match_setup_screen.dart';

// ✅ ADD THESE
import '../match/scoring_screen.dart';
import '../match/match_detail_screen.dart';

enum SortType { time, group, teams, status }

class MatchesTab extends StatefulWidget {
  final int tournamentId;
  final String role;

  const MatchesTab({
    super.key,
    required this.tournamentId,
    required this.role,
  });

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  bool _disposed = false;
  List matches = [];
  bool isLoading = true;

  bool hasLive = false;
  bool hasCompleted = false;
  bool hasUpcoming = false;

  Map<int, String> groupNames = {};
  SortType selectedSort = SortType.time;

  final List<Color> groupColorPool = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  Color getGroupColor(String groupName) {
    final index = groupName.hashCode % groupColorPool.length;
    return groupColorPool[index.abs()];
  }

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadMatches() async {
    try {
      final data =
          await ApiService.getTournamentMatches(widget.tournamentId);

      if (!mounted || _disposed) return;

      final groups =
          await ApiService.getGroups(widget.tournamentId);

      if (!mounted || _disposed) return;

      bool live = false;
      bool completed = false;
      bool upcoming = false;

      for (var m in data) {
        if (m["is_live"] == true) live = true;
        if (m["winner"] != null) completed = true;
        if (m["winner"] == null && m["is_live"] != true) upcoming = true;
      }

      if (!mounted || _disposed) return;

      setState(() {
        matches = data;
        isLoading = false;
        hasLive = live;
        hasCompleted = completed;
        hasUpcoming = upcoming;

        groupNames = {
          for (var g in groups) g["id"]: g["name"]
        };
      });
    } catch (e) {
      if (!mounted || _disposed) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> generateFixtures() async {
    if (hasLive || hasCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tournament already started")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupSetupScreen(
          tournamentId: widget.tournamentId,
          totalTeams: matches.length,
        ),
      ),
    );
  }

  Future<void> openMatchSetup(Map m) async {
    final res = await ApiService.initMatchFromFixture(m["id"]);
    final matchId = res["match_id"];

    if (matchId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchSetupScreen(
          matchId: matchId,
          teamAId: m["team_a_id"] ?? 0,
          teamBId: m["team_b_id"] ?? 0,
          teamAName: m["team_a"] ?? "Team A",
          teamBName: m["team_b"] ?? "Team B",
          tournamentId: widget.tournamentId,
        ),
      ),
    );
  }

  String getStatus(Map m) {
    if (m["winner"] != null) return "COMPLETED";
    if (m["is_live"] == true) return "LIVE";
    return "UPCOMING";
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "LIVE":
        return Colors.red;
      case "COMPLETED":
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  List getSortedMatchesByType() {
    List list = List.from(matches);

    switch (selectedSort) {
      case SortType.time:
        list.sort((a, b) {
          final aLive = a["is_live"] == true;
          final bLive = b["is_live"] == true;

          if (aLive && !bLive) return -1;
          if (!aLive && bLive) return 1;
          return 0;
        });
        break;

      case SortType.group:
        list.sort((a, b) {
          final g1 = groupNames[a["group_id"]] ?? "";
          final g2 = groupNames[b["group_id"]] ?? "";
          return g1.compareTo(g2);
        });
        break;

      case SortType.teams:
        list.sort((a, b) {
          final t1 = (a["team_a"] ?? "") + (a["team_b"] ?? "");
          final t2 = (b["team_a"] ?? "") + (b["team_b"] ?? "");
          return t1.compareTo(t2);
        });
        break;

      case SortType.status:
        list.sort((a, b) {
          int rank(String s) {
            if (s == "LIVE") return 0;
            if (s == "UPCOMING") return 1;
            return 2;
          }
          return rank(getStatus(a)).compareTo(rank(getStatus(b)));
        });
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = getSortedMatchesByType();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matches.isEmpty) {
      return const Center(child: Text("No Fixtures"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sorted.length,
      itemBuilder: (_, i) => _buildMatch(sorted[i]),
    );
  }

  Widget _buildMatch(Map m) {
    final status = getStatus(m);
    final isAdmin = widget.role == "ADMIN";
    final isLive = status == "LIVE";

    return InkWell(
      borderRadius: BorderRadius.circular(16),

      // 🔥 FULLY FIXED NAVIGATION
      onTap: () {
        final matchId = m["match_id"] ?? m["id"];

        if (isAdmin) {
          if (status == "UPCOMING") {
            openMatchSetup(m);
          } else if (status == "LIVE") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScoringScreen(matchId: matchId),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchDetailScreen(
                  matchId: matchId,
                  isAdmin: false,
                ),
              ),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchDetailScreen(
                matchId: matchId,
                isAdmin: false,
              ),
            ),
          );
        }
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Match #${m["id"]}"),
                Text(
                  status,
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text(m["team_a"])),
                const Text(" vs "),
                Expanded(
                  child: Text(
                    m["team_b"],
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isLive)
              const Text(
                "LIVE",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}