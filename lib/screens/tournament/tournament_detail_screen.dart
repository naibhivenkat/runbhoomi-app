import 'package:flutter/material.dart';
import '../../models/tournament_model.dart';
import '../../services/api_service.dart';
import '../match/matches_tab.dart';
import '../match/points_tab.dart';
import '../teams/create_team_screen.dart';
import '../teams/team_requests_screen.dart';
import 'overview_tab.dart';
import 'teams_tab.dart';


class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetailScreen({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),

        body: Column(
          children: [

            /// 🔥 HEADER
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                image: tournament.bannerUrl != null &&
                        tournament.bannerUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(tournament.bannerUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: tournament.bannerUrl == null
                    ? const LinearGradient(
                        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔙 BACK
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),

                        const SizedBox(height: 10),

                        /// 🏆 LOGO + NAME
                        Row(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(16),
                                child: tournament.logoUrl != null &&
                                        tournament.logoUrl!.isNotEmpty
                                    ? Image.network(
                                        tournament.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.emoji_events),
                                      )
                                    : const Icon(Icons.emoji_events),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tournament.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14,
                                          color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        tournament.location,
                                        style: const TextStyle(
                                            color:
                                                Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 🔥 JOIN BUTTON (NEW)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00c6ff),
                                  Color(0xFF0072ff)
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                /// 🔥 OPEN CREATE TEAM
                                final teamId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateTeamScreen(
                                      captainId:
                                          1, // TODO: replace with logged user
                                    ),
                                  ),
                                );

                                /// 🔥 JOIN TOURNAMENT
                                if (teamId != null) {
                                  await ApiService.joinTournament(
                                      tournament.id, teamId);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Request sent")),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12),
                              ),
                              child: const Text(
                                "Join Tournament",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        /// 📊 STATS
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _statItem("Teams",
                                "${tournament.totalTeams ?? 0}"),

                            _statItem(
                                "Start",
                                tournament.startDate != null
                                    ? tournament.startDate!
                                        .split(" ")[0]
                                    : "-"),

                            _statItem(
                                "End",
                                tournament.endDate != null
                                    ? tournament.endDate!
                                        .split(" ")[0]
                                    : "-"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// 🔥 TABS
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Overview"),
                  Tab(text: "Teams"),
                  Tab(text: "Matches"),
                  Tab(text: "Requests"),
                  Tab(text: "Points"),
                ],
              ),
            ),

            /// 🔥 CONTENT
            Expanded(
              child: TabBarView(
                children: [
                  OverviewTab(tournament: tournament),
                 // TeamsTab(tournamentId: tournament.id),
                  TeamsTab(
                    tournamentId: tournament.id,
                    maxTeams: tournament.totalTeams ?? 8 ),
                  MatchesTab(tournamentId: tournament.id),
                  TeamRequestsScreen(tournamentId: tournament.id),
                  PointsTab(tournamentId: tournament.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}