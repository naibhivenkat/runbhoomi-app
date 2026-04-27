
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../match/match_detail_screen.dart';
import '../match/match_setup_screen.dart';
import '../match/scoring_screen.dart';

class AppColors {
  static const primary = Color(0xFF0F172A);
  static const accent = Color(0xFF16A34A);
  static const live = Color(0xFFDC2626);
  static const bg = Color(0xFFF1F5F9);
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
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    fetchMatches();

    _timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (!mounted || _disposed) {
        t.cancel();
        return;
      }
      fetchMatches(silent: true);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMatches({bool silent = false}) async {
    try {
      final email = await SessionService.getEmail();
      if (email == null) return;

      final data = await ApiService.getMatchesByUser(email);

      if (!mounted || _disposed) return;

      setState(() {
        matches = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted || _disposed) return;
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
                physics: const NeverScrollableScrollPhysics(),
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
          ? const Center(child: Text("🏏 No matches yet"))
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

class _MatchTileState extends State<MatchTile> {
  Timer? _timer;
  bool _disposed = false;

  String? score;
  String? overs;
  List lastOver = [];

  bool get isAdmin => widget.match["is_admin"] == true;
  bool get isLive =>
      (widget.match["status"] ?? "").toLowerCase() == "live";
  bool get isCompleted =>
      (widget.match["status"] ?? "").toLowerCase() == "completed";
  bool get isUpcoming =>
      (widget.match["status"] ?? "").toLowerCase() != "live" &&
      !isCompleted;

  @override
  void initState() {
    super.initState();

    if (isLive) {
      _load();
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _load(),
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

Future<void> _load() async {
  try {
    final data = await ApiService.getLive(widget.match["id"]);

    if (!mounted || _disposed) return;

    setState(() {
      score = data["score"];
      overs = data["overs"];
      lastOver = data["last_over"] ?? [];

      /// 🔥 NEW
      runRate = data["run_rate"];
    });
  } catch (_) {}
}

double? runRate;


  void _handleTap() {
    final m = widget.match;

    if (isAdmin) {
      if (isUpcoming) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchSetupScreen(
              matchId: m["id"],
              teamAId: m["teamA_id"],
              teamBId: m["teamB_id"],
              teamAName: m["teamA"],
              teamBName: m["teamB"],
              tournamentId: m["tournament_id"],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScoringScreen(matchId: m["id"]),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(
            matchId: m["id"],
            isAdmin: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    final teamA = m["teamA"] ?? "";
    final teamB = m["teamB"] ?? "";

    final displayScore = score ?? m["scoreA"] ?? "";
    final displayOvers = overs ?? m["overs"] ?? "";

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? Colors.red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
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
                      fontSize: 12, color: Colors.grey),
                ),
                _badge(
                  isLive
                      ? "LIVE"
                      : isCompleted
                          ? "DONE"
                          : "UPCOMING",
                  isLive
                      ? Colors.red
                      : isCompleted
                          ? Colors.green
                          : Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// TEAM A
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(teamA,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayScore.isEmpty ? "Yet to bat" : displayScore,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (displayOvers.isNotEmpty)
                      Text(
                        "($displayOvers)",
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TEAM B
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(teamB,
                    style: const TextStyle(color: Colors.grey)),
                const Text("Yet to bat"),
              ],
            ),



            const SizedBox(height: 10),
            _statusBar(),

            /// LAST OVER
            if (lastOver.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  children: lastOver.map<Widget>((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: e == "W"
                            ? Colors.red.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        e.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              e == "W" ? Colors.red : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 12),

            /// ACTION BUTTON
            if (isAdmin && (isLive || isUpcoming))
              InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLive ? "Continue Scoring" : "Start Match",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

if (!isAdmin) ...[
  if (isUpcoming)
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Waiting to start match",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

  if (isLive)
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Match is live",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
],
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }


Widget _statusBar() {
  /// ================= UPCOMING =================
  if (isUpcoming) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.schedule, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            "Match yet to begin",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= LIVE =================
  if (isLive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔴 LIVE HEADER
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (_, value, child) =>
                    Opacity(opacity: value, child: child),
                onEnd: () => setState(() {}),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "LIVE",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              if (overs != null)
                Text(
                  "$overs ov",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(width: 10),

              if (runRate != null)
                Text(
                  "CRR ${runRate!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          /// ⚡ LAST OVER (INLINE)
          if (lastOver.isNotEmpty)
            Wrap(
              spacing: 6,
              children: lastOver.map<Widget>((e) {
                final isWicket = e == "W";

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWicket
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    e.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isWicket ? Colors.red : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// ================= COMPLETED =================
  if (isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.match["note"] ?? "Match completed",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return const SizedBox();
}
}
