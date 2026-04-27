import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';

class LiveTab extends StatefulWidget {
  final int matchId;

  const LiveTab({super.key, required this.matchId});

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {

  Map<String, dynamic>? liveData;
  List<String> balls = [];

  Timer? _timer;
  final ScrollController _scroll = ScrollController();

  bool _isFetching = false;

  int _lastBallCount = 0;
  String? _event;
  bool _showEvent = false;

  /// ✅ NEW (critical)
  bool _disposed = false;
  final List<Timer> _delayedTimers = [];

  @override
void initState() {
  super.initState();

  _fetchLive();

  // _timer = Timer.periodic(const Duration(seconds: 3), (t) {
  //   if (!mounted || _disposed) {
  //     t.cancel(); // ✅ MUST cancel inside callback
  //     return;
  //   }

  //   _fetchLive();
  // });
}

@override
void dispose() {
  _disposed = true;

  _timer?.cancel();

  for (var t in _delayedTimers) {
    t.cancel();
  }

  _scroll.dispose();

  super.dispose();
}

  Future<void> _fetchLive() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final data = await ApiService.getLive(widget.matchId);

      if (!mounted || _disposed) return;

      final newBalls = List<String>.from(
        (data["last_over"] ?? []).map((e) => e.toString()),
      );

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

      if (!mounted || _disposed) return;

      setState(() {
        liveData = data;
        balls = newBalls;
      });

      _autoScroll();
    } catch (e) {
      debugPrint("Live fetch error: $e");
    } finally {
      if (mounted && !_disposed) {
        _isFetching = false;
      }
    }
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

void _autoScroll() {
  final t = Timer(const Duration(milliseconds: 200), () {
    if (!mounted || _disposed) return;

    if (_scroll.hasClients) {
      try {
        _scroll.jumpTo(
          _scroll.position.maxScrollExtent,
        );
      } catch (e) {
        // ignore scroll errors if disposed mid-frame
      }
    }
  });

  _delayedTimers.add(t);
}

  @override
  Widget build(BuildContext context) {
    if (liveData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final d = liveData!;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _scoreHero(d),
            const SizedBox(height: 12),
            _commentaryBar(d),
            const SizedBox(height: 16),
            _timeline(),
            const SizedBox(height: 20),
            _batsmanCard(d["batsmen"]),
            const SizedBox(height: 20),
            _yetToBatCard(d["yet_to_bat"]),
            const SizedBox(height: 20),
            _bowlerCard(d["bowler"]),
            const SizedBox(height: 20),
            _statsGrid(d),
          ],
        ),
        if (_showEvent) _eventOverlay(),
      ],
    );
  }

Widget _scoreHero(Map d) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
      
        const Text(
          "● LIVE",
          style: TextStyle(color: Colors.orangeAccent),
        ),

        const SizedBox(height: 10),

        Text(
          d["score"] ?? "0/0",
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        Text(
          "(${d["overs"] ?? "0.0"})",
          style: const TextStyle(color: Colors.white70),
        ),

        const SizedBox(height: 8),

        Text(
          d["status"] ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}
  Widget _commentaryBar(Map d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d["status"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (d["note"] != null)
            Text(d["note"], style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

Widget _timeline() {
  if (balls.isEmpty) {
    return const Center(child: Text("No balls yet"));
  }

  return SizedBox(
    height: 60,
    child: ListView.builder(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      itemCount: balls.length,
      itemBuilder: (context, i) {
        final b = balls[i];
        final isLast = i == balls.length - 1;

        Color c = Colors.grey;
        if (b == "4") c = Colors.blue;
        if (b == "6") c = Colors.green;
        if (b == "W") c = Colors.red;

        return Container( 
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isLast ? 44 : 34,
          height: isLast ? 44 : 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: isLast
                ? [
                    BoxShadow(
                      color: c.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
            border:
                isLast ? Border.all(color: Colors.black, width: 2) : null,
          ),
          child: Text(
            b,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    ),
  );
}
  Widget _eventOverlay() {
    String text = "";
    Color color = Colors.white;

    if (_event == "6") {
      text = "SIX!";
      color = Colors.greenAccent;
    } else if (_event == "4") {
      text = "FOUR!";
      color = Colors.blueAccent;
    } else if (_event == "W") {
      text = "WICKET!";
      color = Colors.redAccent;
    }

    return Opacity(
      opacity: _showEvent ? 1 : 0,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
/// 🧑‍🤝‍🧑 BATSMEN
Widget _batsmanCard(List? batsmen) {
  if (batsmen == null || batsmen.isEmpty) {
    return _emptyCard("No batsmen data");
  }

  final activeBatsmen = batsmen
      .where((b) => b["is_out"] != true)
      .toList()
    ..sort((a, b) => (b["is_striker"] == true ? 1 : 0)
        .compareTo(a["is_striker"] == true ? 1 : 0));

  final displayBatsmen = activeBatsmen.take(2).toList();

  return _sectionCard(
    child: Column(
      children: [
        _tableHeader(),
        const Divider(),
        ...displayBatsmen.map((b) {
          final striker = b["is_striker"] == true;

          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: striker ? Colors.green.shade50 : null,
              borderRadius: BorderRadius.circular(10),
              border: striker
                  ? Border.all(color: Colors.green, width: 1.2)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        b["name"] ?? "Unknown",
                        style: TextStyle(
                          fontWeight:
                              striker ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (striker) ...[
                        const SizedBox(width: 6),
                        const Text(
                          "★",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                _cell(b["runs"]),
                _cell(b["balls"]),
                _cell(b["fours"]),
                _cell(b["sixes"]),
                _cell(b["sr"]),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}

Widget _yetToBatCard(List? players) {
  if (players == null || players.isEmpty) return const SizedBox();

  return _sectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Yet to bat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          players.join(", "),
          style: const TextStyle(color: Colors.grey),
        )
      ],
    ),
  );
}

  Widget _tableHeader() => Row(
        children: const [
          Expanded(flex: 3, child: Text("Batter", style: _head)),
          Expanded(child: Text("R", style: _head)),
          Expanded(child: Text("B", style: _head)),
          Expanded(child: Text("4s", style: _head)),
          Expanded(child: Text("6s", style: _head)),
          Expanded(child: Text("SR", style: _head)),
        ],
      );

  /// 🎯 BOWLER
  Widget _bowlerCard(Map? bowler) {
    if (bowler == null) return _emptyCard("No bowler data");

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bowler["name"] ?? "",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mini("Overs", bowler["overs"]),
              _mini("Runs", bowler["runs"]),
              _mini("Wkts", bowler["wickets"]),
              _mini("Eco", bowler["eco"]),
            ],
          )
        ],
      ),
    );
  }

  /// 📊 STATS
  Widget _statsGrid(Map d) {
    return Row(
      children: [
        Expanded(child: _statCard("Run Rate", d["run_rate"])),
        const SizedBox(width: 10),
        Expanded(child: _statCard("Extras", d["extras"])),
      ],
    );
  }

  /// 🧱 COMMON

  Widget _sectionCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: child,
      );

  Widget _statCard(String t, dynamic v) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(),
        child: Column(
          children: [
            Text(t, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text("${v ?? 0}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ],
        ),
      );

  Widget _mini(String t, dynamic v) => Column(
        children: [
          Text(t, style: const TextStyle(fontSize: 11)),
          Text("${v ?? 0}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  Widget _cell(dynamic v) => Expanded(
        child: Text("${v ?? 0}", textAlign: TextAlign.center),
      );

  Widget _emptyCard(String text) => _sectionCard(
        child: Center(child: Text(text)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      );

  static const _head =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w600);
}
  