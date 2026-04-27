import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runbhoomi_app/services/api_service.dart';

import '../../models/match_model.dart';
import 'commentary_tab.dart';
import 'info_tab.dart';
import 'live_tab.dart';
import 'squads_tab.dart';
import 'stats_tab.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  final bool isAdmin; // kept for compatibility (not used now)

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    this.isAdmin = false,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  late Future<MatchModel> matchFuture;

  Map<String, dynamic>? liveData;
  List<String> balls = [];

  Timer? _timer;
  bool _isFetching = false;

  int _lastBallCount = 0;
  String? _event;
  bool _showEvent = false;
  bool _disposed = false;
  final List<Timer> _delayedTimers = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
    matchFuture = ApiService.getMatchDetail(widget.matchId);

    _fetchLive();

    _timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted || _disposed) {
        t.cancel();
        return;
      }
      _fetchLive();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();

    for (var t in _delayedTimers) {
      t.cancel();
    }

    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLive() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final data = await ApiService.getLive(widget.matchId);

      final newBalls = List<String>.from(
        (data["last_over"] ?? []).map((e) => e.toString()),
      );

      if (!mounted || _disposed) return;

      if (newBalls.length < _lastBallCount) {
        _lastBallCount = 0;
      }

      if (newBalls.length > _lastBallCount) {
        final latest = newBalls.last;
        _lastBallCount = newBalls.length;

        if (["6", "4", "W"].contains(latest)) {
          _triggerEvent(latest);
        }
      }

      setState(() {
        liveData = data;
        balls = newBalls;
      });
    } catch (_) {}

    _isFetching = false;
  }

  void _triggerEvent(String type) {
    if (!mounted || _disposed) return;

    HapticFeedback.heavyImpact();

    setState(() {
      _event = type;
      _showEvent = true;
    });

    final t = Timer(const Duration(seconds: 2), () {
      if (!mounted || _disposed) return;
      setState(() => _showEvent = false);
    });

    _delayedTimers.add(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          FutureBuilder<MatchModel>(
            future: matchFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || liveData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final match = snapshot.data!;
              final d = liveData!;

              /// ✅ CLEAN VIEW-ONLY UI (NO ADMIN PANEL)
              return NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    _buildSliverHeader(match, d),
                    _buildTabBar(),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    LiveTab(matchId: widget.matchId),
                    InfoTab(match: match),
                    CommentaryTab(matchId: widget.matchId),
                    SquadsTab(matchId: widget.matchId),
                    StatsTab(matchId: widget.matchId),
                  ],
                ),
              );
            },
          ),

          if (_showEvent) _eventOverlay(),
        ],
      ),
    );
  }

  /// =======================
  /// 🎬 EVENT OVERLAY
  /// =======================
  Widget _eventOverlay() {
    String text = "";

    if (_event == "6") text = "SIX!";
    if (_event == "4") text = "FOUR!";
    if (_event == "W") text = "WICKET!";

    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// =======================
  /// 🧾 HEADER
  /// =======================
  Widget _buildSliverHeader(MatchModel match, Map d) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            ),
          ),
          child: Column(
            children: [
              const Text("● LIVE",
                  style: TextStyle(color: Colors.orangeAccent)),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _teamMini(match.team1),
                  Column(
                    children: [
                      Text(
                        d["score"] ?? match.score1,
                        style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "(${d["overs"] ?? ""})",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  _teamMini(match.team2),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                d["status"] ?? "Live",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Last Over",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  _premiumBalls(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumBalls() {
    if (balls.isEmpty) {
      return const Text("No balls yet",
          style: TextStyle(color: Colors.white70));
    }

    return Row(
      children: balls.map((b) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _ballColor(b),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            b,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Color _ballColor(String b) {
    if (b == "4" || b == "6") return Colors.green;
    if (b == "W") return Colors.red;
    return Colors.blue;
  }

  Widget _teamMini(String name) {
    return Column(
      children: [
        CircleAvatar(child: Text(name[0])),
        Text(name, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Live"),
            Tab(text: "Info"),
            Tab(text: "Commentary"),
            Tab(text: "Squads"),
            Tab(text: "Stats"),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_) => false;
}


