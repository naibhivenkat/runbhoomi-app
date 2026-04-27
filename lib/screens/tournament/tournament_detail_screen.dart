import 'package:flutter/material.dart';
import '../../models/tournament_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../match/matches_tab.dart';
import '../match/points_tab.dart';
import '../teams/create_team_screen.dart';
import '../teams/team_requests_screen.dart';
import 'overview_tab.dart';
import 'teams_tab.dart';

import 'package:intl/intl.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with TickerProviderStateMixin {
  String role = "PLAYER";
  late AnimationController _pulse;
  late AnimationController _progressAnim;

  @override
  void initState() {
    super.initState();
    loadRole();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  Future loadRole() async {
    try {
      final res = await ApiService.getMyRole(widget.tournament.id);
      if (!mounted) return;
      setState(() => role = res["role"] ?? "PLAYER");
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulse.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    return DateFormat("d MMM yyyy").format(d);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final isAdmin = role == "ADMIN";

    final maxTeams = t.totalTeams ?? 8;
    final currentTeams = t.totalTeams ?? 8;
    final isFull = currentTeams >= maxTeams;

    return DefaultTabController(
      key: ValueKey(role),
      length: isAdmin ? 5 : 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        body: NestedScrollView(
          physics: const ClampingScrollPhysics(),

          headerSliverBuilder: (context, _) {
            return [

              /// 🔥 PREMIUM APPBAR
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                backgroundColor: const Color(0xFF0B6E4F),
                elevation: 0,

                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),



                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
  padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF11998E),
        Color(0xFF0B6E4F),
        Color(0xFF093028),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 🔥 FULL BADGE (NOW COLLAPSIBLE)
      if (isFull)
        Align(
          alignment: Alignment.topRight,
          child: _badge("FULL"),
        ),

      const Spacer(),

      /// 🔥 HEADER CARD
      _buildHeaderCard(t, isFull, maxTeams, currentTeams),
    ],
  ),
),
                ),
              ),

              /// TABS
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    indicatorWeight: 3,
                    tabs: isAdmin
                        ? const [
                            Tab(text: "Overview"),
                            Tab(text: "Teams"),
                            Tab(text: "Matches"),
                            Tab(text: "Requests"),
                            Tab(text: "Points"),
                          ]
                        : const [
                            Tab(text: "Overview"),
                            Tab(text: "Teams"),
                            Tab(text: "Matches"),
                            Tab(text: "Points"),
                          ],
                  ),
                ),
              ),
            ];
          },

          body: TabBarView(
            children: isAdmin
                ? [
                    OverviewTab(tournament: t),
                    TeamsTab(tournamentId: t.id, maxTeams: maxTeams),
                    MatchesTab(tournamentId: t.id, role: role),
                    TeamRequestsScreen(tournamentId: t.id),
                    PointsTab(tournamentId: t.id),
                  ]
                : [
                    OverviewTab(tournament: t),
                    TeamsTab(tournamentId: t.id, maxTeams: maxTeams),
                    MatchesTab(tournamentId: t.id, role: role),
                    PointsTab(tournamentId: t.id),
                  ],
          ),
        ),
      ),
    );
  }

  /// 🔥 ULTRA PREMIUM CARD
  Widget _buildHeaderCard(t, isFull, maxTeams, currentTeams) {
    final progress = currentTeams / maxTeams;

    Color progressColor = isFull
        ? Colors.redAccent
        : (progress > 0.7)
            ? Colors.orange
            : Colors.greenAccent;

    return FadeTransition(
      opacity: _progressAnim,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                _logo(t.logoUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(t.location,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// PROGRESS
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) {
                  return LinearProgressIndicator(
                    value: progress * _progressAnim.value,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation(progressColor),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "$currentTeams / $maxTeams Teams Joined",
              style:
                  const TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 18),

            /// STATS
            Row(
              children: [
                Expanded(child: _miniStat("Teams", "$maxTeams")),
                Expanded(child: _miniStat("Start", formatDate(t.startDate))),
                Expanded(child: _miniStat("End", formatDate(t.endDate))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 4),
        Text(title,
            style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _logo(String? url) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          )
        ],
      ),
      child: url != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(url, fit: BoxFit.cover),
            )
          : const Icon(Icons.emoji_events),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_) => false;
}
