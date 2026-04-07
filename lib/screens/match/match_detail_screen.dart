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

  const MatchDetailScreen({super.key, required this.matchId});

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

  /// 🔥 EVENT SYSTEM
  int _lastBallCount = 0;
  String? _event;
  bool _showEvent = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
    matchFuture = ApiService.getMatchDetail(widget.matchId);

    _fetchLive();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchLive();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _tabController.dispose();
    super.dispose();
  }

  /// 🔥 SAFE LIVE FETCH
  Future<void> _fetchLive() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final data = await ApiService.getLive(widget.matchId);

      final newBalls = List<String>.from(
        (data["last_over"] ?? []).map((e) => e.toString()),
      );

      if (!mounted) return;

      /// RESET HANDLING
      if (newBalls.length < _lastBallCount) {
        _lastBallCount = 0;
      }

      /// EVENT DETECTION
      if (newBalls.length > _lastBallCount) {
        final latest = newBalls.last;
        _lastBallCount = newBalls.length;

        if (["6", "4", "W"].contains(latest)) {
          _triggerEvent(latest);
        }
      }

      if (!mounted) return;

      setState(() {
        liveData = data;
        balls = newBalls;
      });
    } catch (e) {
      debugPrint("Live error: $e");
    } finally {
      _isFetching = false;
    }
  }

  /// 🔥 SAFE EVENT TRIGGER
  void _triggerEvent(String type) {
    if (!mounted) return;

    HapticFeedback.heavyImpact();

    setState(() {
      _event = type;
      _showEvent = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showEvent = false);
    });
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

              return NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    _buildSliverHeader(match, d),
                    _buildTabBar(),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
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




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:runbhoomi_app/services/api_service.dart';

// import '../../models/match_model.dart';
// import 'commentary_tab.dart';
// import 'info_tab.dart';
// import 'live_tab.dart';
// import 'squads_tab.dart';
// import 'stats_tab.dart';

// class MatchDetailScreen extends StatefulWidget {
//   final int matchId;

//   const MatchDetailScreen({super.key, required this.matchId});

//   @override
//   State<MatchDetailScreen> createState() => _MatchDetailScreenState();
// }

// class _MatchDetailScreenState extends State<MatchDetailScreen>
//     with SingleTickerProviderStateMixin {

//   late TabController _tabController;
//   late Future<MatchModel> matchFuture;

//   Map<String, dynamic>? liveData;
//   List<String> balls = [];

//   Timer? _timer;

//   /// 🔥 EVENT SYSTEM
//   int _lastBallCount = 0;
//   String? _event;
//   bool _showEvent = false;

//   @override
//   void initState() {
//     super.initState();

//     _tabController = TabController(length: 5, vsync: this);
//     matchFuture = ApiService.getMatchDetail(widget.matchId);

//     _fetchLive();

//     _timer = Timer.periodic(const Duration(seconds: 2), (_) {
//       _fetchLive();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchLive() async {
//     try {
//       final data = await ApiService.getLive(widget.matchId);

//       final newBalls = List<String>.from(
//         (data["last_over"] ?? []).map((e) => e.toString()),
//       );

//       /// RESET HANDLING
//       if (newBalls.length < _lastBallCount) {
//         _lastBallCount = 0;
//       }

//       /// EVENT DETECTION
//       if (newBalls.length > _lastBallCount) {
//         final latest = newBalls.last;
//         _lastBallCount = newBalls.length;

//         if (["6", "4", "W"].contains(latest)) {
//           _triggerEvent(latest);
//         }
//       }

//       if (mounted) {
//         setState(() {
//           liveData = data;
//           balls = newBalls;
//         });
//       }
//     } catch (e) {
//       debugPrint("Live error: $e");
//     }
//   }

//   void _triggerEvent(String type) {
//     HapticFeedback.heavyImpact();

//     setState(() {
//       _event = type;
//       _showEvent = true;
//     });

//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
//       setState(() => _showEvent = false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       body: Stack(
//         children: [
//           FutureBuilder<MatchModel>(
//             future: matchFuture,
//             builder: (context, snapshot) {
//               if (!snapshot.hasData || liveData == null) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final match = snapshot.data!;
//               final d = liveData!;

//               return NestedScrollView(
//                 headerSliverBuilder: (context, _) {
//                   return [
//                     _buildSliverHeader(match, d),
//                     _buildTabBar(),
//                   ];
//                 },
//                 body: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     LiveTab(matchId: widget.matchId),
//                     InfoTab(match: match),
//                     CommentaryTab(matchId: widget.matchId),
//                     SquadsTab(matchId: widget.matchId),
//                     StatsTab(matchId: widget.matchId),
//                   ],
//                 ),
//               );
//             },
//           ),

//           if (_showEvent) _eventOverlay(),
//         ],
//       ),
//     );
//   }

//   /// 🔥 HEADER (LIVE FIXED)
//   Widget _buildSliverHeader(MatchModel match, Map d) {
//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
//             ),
//           ),
//           child: Column(
//             children: [
//               const Text("● LIVE",
//                   style: TextStyle(color: Colors.orangeAccent)),

//               const SizedBox(height: 10),

//               /// 🔥 LIVE SCORE (FIXED)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _teamMini(match.team1),
//                   Column(
//                     children: [
//                       Text(
//                         d["score"] ?? match.score1,
//                         style: const TextStyle(
//                             fontSize: 28,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         "(${d["overs"] ?? ""})",
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                   _teamMini(match.team2),
//                 ],
//               ),

//               const SizedBox(height: 10),

//               Text(
//                 d["status"] ?? "Live",
//                 style: const TextStyle(color: Colors.white),
//               ),

//               const SizedBox(height: 12),

//               /// 🔥 LAST OVER (NOW WORKS)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Last Over",
//                       style: TextStyle(color: Colors.white70)),
//                   const SizedBox(height: 8),
//                   _premiumBalls(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _premiumBalls() {
//     if (balls.isEmpty) {
//       return const Text("No balls yet",
//           style: TextStyle(color: Colors.white70));
//     }

//     return Row(
//       children: balls.asMap().entries.map((e) {
//         int i = e.key;
//         String b = e.value;

//         final isLast = i == balls.length - 1;

//         return Container(
//           margin: const EdgeInsets.only(right: 6),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: _ballColor(b),
//             borderRadius: BorderRadius.circular(10),
//             border: isLast
//                 ? Border.all(color: Colors.white, width: 2)
//                 : null,
//           ),
//           child: Text(
//             b,
//             style: const TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   /// 💥 EVENT
//   Widget _eventOverlay() {
//     String text = "";
//     Color color = Colors.white;

//     if (_event == "6") text = "SIX!";
//     if (_event == "4") text = "FOUR!";
//     if (_event == "W") text = "WICKET!";

//     return Container(
//       color: Colors.black.withOpacity(0.75),
//       child: Center(
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 60,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ),
//     );
//   }

//   Color _ballColor(String b) {
//     if (b == "4" || b == "6") return Colors.green;
//     if (b == "W") return Colors.red;
//     return Colors.blue;
//   }

//   Widget _teamMini(String name) {
//     return Column(
//       children: [
//         CircleAvatar(child: Text(name[0])),
//         Text(name, style: const TextStyle(color: Colors.white)),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: "Live"),
//             Tab(text: "Info"),
//             Tab(text: "Commentary"),
//             Tab(text: "Squads"),
//             Tab(text: "Stats"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(context, shrinkOffset, overlapsContent) {
//     return Container(color: Colors.white, child: tabBar);
//   }

//   @override
//   bool shouldRebuild(_) => false;
// }



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:runbhoomi_app/services/api_service.dart';

// import '../../models/match_model.dart';
// import 'commentary_tab.dart';
// import 'info_tab.dart';
// import 'live_tab.dart';
// import 'squads_tab.dart';
// import 'stats_tab.dart';

// class MatchDetailScreen extends StatefulWidget {
//   final int matchId;

//   const MatchDetailScreen({super.key, required this.matchId});

//   @override
//   State<MatchDetailScreen> createState() => _MatchDetailScreenState();
// }

// class _MatchDetailScreenState extends State<MatchDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Future<MatchModel> matchFuture;

//   List<String> balls = [];
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();

//     _tabController = TabController(length: 5, vsync: this);
//     matchFuture = ApiService.getMatchDetail(widget.matchId);

//     _loadBalls();

//     _timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       _loadBalls();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBalls() async {
//     try {
//       final newBalls =
//           await ApiService.getLastBalls(widget.matchId);

//       if (mounted) {
//         setState(() {
//           balls = newBalls;
//         });
//       }
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       body: FutureBuilder<MatchModel>(
//         future: matchFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final match = snapshot.data!;

//           return NestedScrollView(
//             headerSliverBuilder: (context, _) {
//               return [
//                 _buildSliverHeader(match),
//                 _buildTabBar(),
//               ];
//             },
//             body: TabBarView(
//               controller: _tabController,
//               children: [
//                 LiveTab(matchId: widget.matchId),
//                 InfoTab(match: match),
//                 CommentaryTab(matchId: widget.matchId),
//                 SquadsTab(matchId: widget.matchId),
//                 StatsTab(matchId: widget.matchId),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// 🔥 HEADER
//   Widget _buildSliverHeader(MatchModel match) {
//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context),
//       ),
//       flexibleSpace: LayoutBuilder(
//         builder: (context, constraints) {
//           double percent =
//               (constraints.maxHeight - kToolbarHeight) / 200;

//           percent = percent.clamp(0.0, 1.0);

//           return FlexibleSpaceBar(
//             background: Container(
//               padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics:
//                           const NeverScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           /// LIVE
//                           Opacity(
//                             opacity: percent,
//                             child: const Text(
//                               "● LIVE",
//                               style: TextStyle(
//                                 color: Colors.orange,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           /// TEAMS
//                           Row(
//                             mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                             children: [
//                               _team(match.team1, match.score1, percent),
//                               Text("VS",
//                                   style: TextStyle(
//                                       color: Colors.white
//                                           .withOpacity(percent))),
//                               _team(match.team2, match.score2, percent),
//                             ],
//                           ),

//                           const SizedBox(height: 10),

//                           /// WIN PROBABILITY
//                           Opacity(
//                             opacity: percent,
//                             child: _winProbability(match),
//                           ),

//                           const SizedBox(height: 10),

//                           /// 🔥 BALL TIMELINE (LIVE DATA)
//                           Opacity(
//                             opacity: percent,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   "Last Over",
//                                   style: TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 12),
//                                 ),
//                                 const SizedBox(height: 6),

//                                 _ballTimeline(
//                                   balls.isNotEmpty ? balls : [],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// 🟢 WIN PROB
//   Widget _winProbability(MatchModel match) {
//     double teamA = 65;
//     double teamB = 35;

//     return Column(
//       children: [
//         const Text(
//           "Win Probability",
//           style: TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: teamA.toInt(),
//                 child: Container(
//                     height: 8, color: Colors.greenAccent),
//               ),
//               Expanded(
//                 flex: teamB.toInt(),
//                 child: Container(
//                     height: 8, color: Colors.redAccent),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment:
//               MainAxisAlignment.spaceBetween,
//           children: [
//             Text("${match.team1} $teamA%",
//                 style: const TextStyle(color: Colors.white)),
//             Text("${match.team2} $teamB%",
//                 style: const TextStyle(color: Colors.white)),
//           ],
//         )
//       ],
//     );
//   }

//   /// 🔥 BALL TIMELINE
//   Widget _ballTimeline(List<String> balls) {
//     return SizedBox(
//       height: 42,
//       child: balls.isEmpty
//           ? const Center(
//               child: Text(
//                 "No balls yet",
//                 style: TextStyle(color: Colors.white70),
//               ),
//             )
//           : ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: balls.length,
//               itemBuilder: (context, i) {
//                 final b = balls[i];

//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 400),
//                   margin: const EdgeInsets.only(right: 6),
//                   width: 34,
//                   decoration: BoxDecoration(
//                     color: _ballColor(b),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       b,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Color _ballColor(String b) {
//     if (b == "4" || b == "6") return Colors.green;
//     if (b == "W") return Colors.red;
//     if (b == "0") return Colors.grey;
//     return Colors.blue;
//   }

//   /// TEAM
//   Widget _team(String name, String score, double scale) {
//     return Column(
//       children: [
//         Transform.scale(
//           scale: 0.8 + (scale * 0.4),
//           child: CircleAvatar(
//             backgroundColor: Colors.white,
//             child: Text(name[0]),
//           ),
//         ),
//         Opacity(
//           opacity: scale,
//           child: Text(name,
//               style: const TextStyle(color: Colors.white)),
//         ),
//         Text(score,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   /// TAB BAR
//   Widget _buildTabBar() {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         TabBar(
//           controller: _tabController,
//           labelColor: Colors.blue,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.blue,
//           tabs: const [
//             Tab(text: "Live"),
//             Tab(text: "Info"),
//             Tab(text: "Commentary"),
//             Tab(text: "Squads"),
//             Tab(text: "Stats"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// TAB DELEGATE
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;

//   _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(context, shrinkOffset, overlapsContent) {
//     return Container(color: Colors.white, child: tabBar);
//   }

//   @override
//   bool shouldRebuild(_) => false;
// }


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:runbhoomi_app/services/api_service.dart';

// import '../../models/match_model.dart';
// import 'commentary_tab.dart';
// import 'info_tab.dart';
// import 'live_tab.dart';
// import 'squads_tab.dart';
// import 'stats_tab.dart';

// class MatchDetailScreen extends StatefulWidget {
//   final int matchId;

//   const MatchDetailScreen({super.key, required this.matchId});

//   @override
//   State<MatchDetailScreen> createState() => _MatchDetailScreenState();
// }

// class _MatchDetailScreenState extends State<MatchDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Future<MatchModel> matchFuture;

//   List<String> balls = [];
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();

//     _tabController = TabController(length: 5, vsync: this);
//     matchFuture = ApiService.getMatchDetail(widget.matchId);

//     _loadBalls();

//     _timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       _loadBalls();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBalls() async {
//     try {
//       final newBalls =
//           await ApiService.getLastBalls(widget.matchId);

//       if (mounted) {
//         setState(() {
//           balls = newBalls;
//         });
//       }
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       body: FutureBuilder<MatchModel>(
//         future: matchFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final match = snapshot.data!;

//           return NestedScrollView(
//             headerSliverBuilder: (context, _) {
//               return [
//                 _buildSliverHeader(match),
//                 _buildTabBar(),
//               ];
//             },
//             body: TabBarView(
//               controller: _tabController,
//               children: [
//                 LiveTab(matchId: widget.matchId),
//                 InfoTab(match: match),
//                 CommentaryTab(matchId: widget.matchId),
//                 SquadsTab(matchId: widget.matchId),
//                 StatsTab(matchId: widget.matchId),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// 🔥 HEADER (FIXED OVERFLOW)
//   Widget _buildSliverHeader(MatchModel match) {
//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context),
//       ),
//       flexibleSpace: LayoutBuilder(
//         builder: (context, constraints) {
//           double percent =
//               (constraints.maxHeight - kToolbarHeight) / 200;

//           percent = percent.clamp(0.0, 1.0);

//           return FlexibleSpaceBar(
//             background: Container(
//               padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics:
//                           const NeverScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           /// LIVE
//                           Opacity(
//                             opacity: percent,
//                             child: const Text(
//                               "● LIVE",
//                               style: TextStyle(
//                                 color: Colors.orange,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           /// TEAMS
//                           Row(
//                             mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                             children: [
//                               _team(match.team1, match.score1, percent),
//                               Text("VS",
//                                   style: TextStyle(
//                                       color: Colors.white
//                                           .withOpacity(percent))),
//                               _team(match.team2, match.score2, percent),
//                             ],
//                           ),

//                           const SizedBox(height: 10),

//                           /// WIN PROBABILITY
//                           Opacity(
//                             opacity: percent,
//                             child: _winProbability(match),
//                           ),

//                           const SizedBox(height: 10),

//                           /// BALL TIMELINE (SAFE)
//                           Opacity(
//                             opacity: percent,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   "Last Over",
//                                   style: TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 12),
//                                 ),
//                                 const SizedBox(height: 6),
                            
//                                 _ballTimeline(
//                                  ["1", "4", "0", "W", "6", "2"],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// 🟢 WIN PROB
//   Widget _winProbability(MatchModel match) {
//     double teamA = 65;
//     double teamB = 35;

//     return Column(
//       children: [
//         const Text(
//           "Win Probability",
//           style: TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: teamA.toInt(),
//                 child: Container(
//                     height: 8, color: Colors.greenAccent),
//               ),
//               Expanded(
//                 flex: teamB.toInt(),
//                 child: Container(
//                     height: 8, color: Colors.redAccent),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment:
//               MainAxisAlignment.spaceBetween,
//           children: [
//             Text("${match.team1} $teamA%",
//                 style: const TextStyle(color: Colors.white)),
//             Text("${match.team2} $teamB%",
//                 style: const TextStyle(color: Colors.white)),
//           ],
//         )
//       ],
//     );
//   }

//   /// 🔥 BALL TIMELINE
//   Widget _ballTimeline(List<String> balls) {
//     return SizedBox(
//       height: 42,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: balls.length,
//         itemBuilder: (context, i) {
//           final b = balls[i];

//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             margin: const EdgeInsets.only(right: 6),
//             width: 34,
//             decoration: BoxDecoration(
//               color: _ballColor(b),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 b,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Color _ballColor(String b) {
//     if (b == "4" || b == "6") return Colors.green;
//     if (b == "W") return Colors.red;
//     if (b == "0") return Colors.grey;
//     return Colors.blue;
//   }

//   /// TEAM
//   Widget _team(String name, String score, double scale) {
//     return Column(
//       children: [
//         Transform.scale(
//           scale: 0.8 + (scale * 0.4),
//           child: CircleAvatar(
//             backgroundColor: Colors.white,
//             child: Text(name[0]),
//           ),
//         ),
//         Opacity(
//           opacity: scale,
//           child: Text(name,
//               style: const TextStyle(color: Colors.white)),
//         ),
//         Text(score,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   /// TAB BAR
//   Widget _buildTabBar() {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         TabBar(
//           controller: _tabController,
//           labelColor: Colors.blue,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.blue,
//           tabs: const [
//             Tab(text: "Live"),
//             Tab(text: "Info"),
//             Tab(text: "Commentary"),
//             Tab(text: "Squads"),
//             Tab(text: "Stats"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// TAB DELEGATE
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;

//   _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(context, shrinkOffset, overlapsContent) {
//     return Container(color: Colors.white, child: tabBar);
//   }

//   @override
//   bool shouldRebuild(_) => false;
// }
