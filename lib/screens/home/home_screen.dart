import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../match/match_detail_screen.dart';

class AppColors {
  static const primary = Color(0xFF0F172A);
  static const accent = Color(0xFF16A34A);
  static const live = Color(0xFFDC2626);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List matches = [];
  bool loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMatches();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMatches(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMatches({bool silent = false}) async {
    try {
      final email = await SessionService.getEmail();
      if (email == null) return;

      final data = await ApiService.getMatches(email);

      if (!mounted) return;

      setState(() {
        matches = data;
        loading = false;
      });
    } catch (e) {
      if (!silent) setState(() => loading = false);
    }
  }

  List filter(String type) {
    return matches.where((m) {
      final status = (m["status"] ?? "").toLowerCase();
      if (type == "live") return status == "live";
      if (type == "completed") return status == "completed";
      return status == "scheduled" ||
          status == "upcoming" ||
          status == "not_started";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "RunBhoomi",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: "Live"),
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(filter("live")),
                  _buildList(filter("scheduled")),
                  _buildList(filter("completed")),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List list) {
    return RefreshIndicator(
      onRefresh: fetchMatches,
      child: list.isEmpty
          ? const Center(child: Text("No matches"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) => MatchTile(match: list[i]),
            ),
    );
  }
}

class MatchTile extends StatefulWidget {
  final Map match;
  const MatchTile({super.key, required this.match});

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  String? scoreA;
  String? scoreB;
  String? overs;
  String? result;
  String? chase;
  List lastOver = [];

  late AnimationController _pulse;

  bool get isLive =>
      (widget.match["status"] ?? "").toLowerCase() == "live";

  bool get isCompleted =>
      (widget.match["status"] ?? "").toLowerCase() == "completed";

  bool get isUpcoming {
    final status = (widget.match["status"] ?? "").toLowerCase();
    return status == "scheduled" ||
        status == "upcoming" ||
        status == "not_started";
  }

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    if (isLive) {
      _load();
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
    }
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getLive(widget.match["id"]);

      if (!mounted) return;

      setState(() {
        scoreA = data["scoreA"] ?? data["score"];
        scoreB = data["scoreB"];
        overs = data["overs"];
        lastOver = data["lastOver"] ?? [];
        result = data["result"];

        if (data["target"] != null && scoreA != null) {
          final runs = int.tryParse(scoreA!.split('/')[0]) ?? 0;
          final target = data["target"];

          final ballsBowled = _oversToBalls(overs ?? "0");
          final totalBalls = (data["totalOvers"] ?? 20) * 6;
          final ballsLeft = totalBalls - ballsBowled;

          final runsNeeded = target - runs;

          if (runsNeeded > 0 && ballsLeft > 0) {
            final rrr =
                (runsNeeded / (ballsLeft / 6)).toStringAsFixed(2);
            chase =
                "$runsNeeded needed • $ballsLeft balls • RRR $rrr";
          }
        }
      });
    } catch (_) {}
  }

  int _oversToBalls(String overs) {
    if (!overs.contains('.')) return int.parse(overs) * 6;
    final parts = overs.split('.');
    return int.parse(parts[0]) * 6 + int.parse(parts[1]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    final teamA = m["teamA"] ?? "";
    final teamB = m["teamB"] ?? "";

    final sA = scoreA ?? m["scoreA"] ?? "";
    final sB = scoreB ?? m["scoreB"] ?? "";
    final ov = overs ?? m["overs"] ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailScreen(matchId: m["id"]),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FAFC)],
          ),
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? Colors.red.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  m["tournament"] ?? "League Match",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                Row(
                  children: [
                    if (isLive)
                      ScaleTransition(
                        scale: _pulse,
                        child: _buildBadge("LIVE", Colors.red, Colors.white),
                      )
                    else if (isCompleted)
                      _buildBadge("COMPLETED",
                          Colors.green.withOpacity(0.15), Colors.green)
                    else if (isUpcoming)
                      _buildBadge("UPCOMING",
                          Colors.blue.withOpacity(0.12), Colors.blue),
                  ],
                )
              ],
            ),

            const SizedBox(height: 14),

            _teamRow(teamA, sA, ov, true, m["teamA_logo"]),
            const SizedBox(height: 10),
            _teamRow(teamB, sB, null, false, m["teamB_logo"]),

            const SizedBox(height: 14),

            if (chase != null)
              Text(
                chase!,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

            if (lastOver.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: lastOver.map((b) {
                    Color bg = Colors.grey.shade200;
                    if (b == "W") bg = Colors.red;
                    if (b == "4") bg = Colors.green;
                    if (b == "6") bg = Colors.green.shade700;

                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.toString(),
                        style: TextStyle(
                          color: bg == Colors.grey.shade200
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            if (widget.match["note"] != null &&
                widget.match["note"].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.match["note"],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 114, 4, 230),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (result != null)
              Text(
                result!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _teamRow(
      String name, String? score, String? overs, bool highlight, String? logo) {
    final displayScore =
        (score == null || score == "") ? "Yet to bat" : score;
         final alreadyHasOvers = displayScore.contains("(");

    return Row(
      children: [
        logo != null && logo.isNotEmpty
            ? CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(logo),
                backgroundColor: Colors.white,
              )
            : CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Text(name.isNotEmpty ? name[0] : "T"),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  highlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayScore,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 17),
                  overflow: TextOverflow.ellipsis, 
            ),
           

if (!alreadyHasOvers && overs != null && overs.isNotEmpty)
  Text(
    "($overs)",
    textAlign: TextAlign.right,
    style: const TextStyle(
      fontSize: 11,
      color: Colors.grey,
    ),
  ),
          ],
        ),
      ],
    );
  }
}
