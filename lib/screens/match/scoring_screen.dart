import 'package:flutter/material.dart';
import 'package:runbhoomi_app/services/api_service.dart';


class ScoringScreen extends StatefulWidget {
  final int matchId;


  const ScoringScreen({
    Key? key,
    required this.matchId,

  }) : super(key: key);

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  bool isLoading = true;

  // Local State for Optimistic UI
  int totalRuns = 0;
  int wickets = 0;
  int totalBalls = 0; 
  int totalExtras = 0;

  List<dynamic> batsmen = [];
  List<String> lastOver = [];
  
  Map<String, dynamic> currentBowler = {
    "name": "Current Bowler",
    "overs": "0.0",
    "runs": 0,
    "wickets": 0,
    "economy": 0.0
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveScore();
  }

  // ==========================================
  // API Calls
  // ==========================================
  Future<void> _fetchLiveScore({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);
    try {
      final res = await ApiService.getLive(widget.matchId);
      
      String scoreStr = res['score'] ?? "0/0";
      List<String> sParts = scoreStr.split('/');
      
      String oversStr = res['overs'] ?? "0.0";
      List<String> oParts = oversStr.split('.');
      
      setState(() {
        totalRuns = int.tryParse(sParts[0]) ?? 0;
        wickets = int.tryParse(sParts.length > 1 ? sParts[1] : "0") ?? 0;
        
        int overBalls = (int.tryParse(oParts[0]) ?? 0) * 6;
        int remainingBalls = int.tryParse(oParts.length > 1 ? oParts[1] : "0") ?? 0;
        totalBalls = overBalls + remainingBalls;

        batsmen = res['batsmen'] ?? [];
        lastOver = List<String>.from(res['last_over'] ?? []);
        totalExtras = res['extras'] ?? 0;
        
        // If API provides bowler, map it here. Otherwise, keep current local state.
        if (res['current_bowler'] != null) {
          currentBowler = res['current_bowler'];
        }

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching live score: $e");
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // Optimistic UI Logic (Zero Delay Scoring)
  // ==========================================
  void _scoreRun(int runs, {bool isWide = false, bool isNoBall = false, bool isWicket = false}) {
    setState(() {
      bool isLegalDelivery = !isWide && !isNoBall;
      int runsToAdd = runs + (isLegalDelivery ? 0 : 1); // Wides/NBs add 1 extra run
      
      totalRuns += runsToAdd;
      if (isWicket) wickets += 1;
      
      if (isLegalDelivery) {
        totalBalls += 1;
      } else {
        totalExtras += runsToAdd; // Add the penalty + any extra runs run by batter
      }

      // 1. FIX: Manage "This Over" Timeline (Clear if 6 legal deliveries are reached)
      int legalBallsInTimeline = lastOver.where((e) => 
        !e.contains('WD') && !e.contains('NB')
      ).length;
      
      if (legalBallsInTimeline >= 6 && isLegalDelivery) {
        lastOver.clear(); // Reset timeline for new over locally
      }

      String timelineEntry = "";
      if (isWicket) timelineEntry = "W";
      else if (isWide) timelineEntry = runs > 0 ? "WD+$runs" : "WD";
      else if (isNoBall) timelineEntry = runs > 0 ? "NB+$runs" : "NB";
      else timelineEntry = runs.toString();
      
      lastOver.add(timelineEntry);

      // 2. FIX: Update Batter Stats (Including 4s and 6s)
      if (batsmen.isNotEmpty) {
        int strikerIndex = batsmen.indexWhere((b) => b['is_striker'] == true);
        if (strikerIndex != -1) {
          if (isLegalDelivery) {
            batsmen[strikerIndex]['balls'] = (batsmen[strikerIndex]['balls'] ?? 0) + 1;
          }
          // Note: Runs on Wides usually don't count to batter, but Runs on NB do. 
          // Adjust logic here based on your exact tournament rules.
          if (!isWide) {
            batsmen[strikerIndex]['runs'] = (batsmen[strikerIndex]['runs'] ?? 0) + runs;
            if (runs == 4) batsmen[strikerIndex]['fours'] = (batsmen[strikerIndex]['fours'] ?? 0) + 1;
            if (runs == 6) batsmen[strikerIndex]['sixes'] = (batsmen[strikerIndex]['sixes'] ?? 0) + 1;
          }
          
          if (isWicket) {
             batsmen[strikerIndex]['is_striker'] = false; 
          }
        }
      }

      // 3. FIX: Update Bowler Stats
      int bRuns = (currentBowler['runs'] ?? 0) + runsToAdd;
      int bWickets = (currentBowler['wickets'] ?? 0) + (isWicket ? 1 : 0);
      String bOversStr = currentBowler['overs']?.toString() ?? "0.0";
      
      int bO = int.tryParse(bOversStr.split('.')[0]) ?? 0;
      int bB = int.tryParse(bOversStr.split('.').length > 1 ? bOversStr.split('.')[1] : "0") ?? 0;

      if (isLegalDelivery) {
        bB += 1;
        if (bB == 6) {
          bO += 1;
          bB = 0;
        }
      }
      
      currentBowler['runs'] = bRuns;
      currentBowler['wickets'] = bWickets;
      currentBowler['overs'] = "$bO.$bB";
      
      int totalBowlerBalls = (bO * 6) + bB;
      if (totalBowlerBalls > 0) {
         currentBowler['economy'] = double.parse((bRuns / (totalBowlerBalls / 6)).toStringAsFixed(1));
      }

      // 4. Rotate Strike locally
      if (!isWicket && batsmen.length >= 2) {
        bool shouldSwap = false;
        if (runs % 2 != 0) shouldSwap = true; // Odd runs swap strike
        if (isLegalDelivery && totalBalls % 6 == 0) shouldSwap = !shouldSwap; // End of over swaps strike
        
        if (shouldSwap) {
          int strikerIdx = batsmen.indexWhere((b) => b['is_striker'] == true);
          int nonStrikerIdx = batsmen.indexWhere((b) => b['is_striker'] == false);
          if (strikerIdx != -1 && nonStrikerIdx != -1) {
            batsmen[strikerIdx]['is_striker'] = false;
            batsmen[nonStrikerIdx]['is_striker'] = true;
          }
        }
      }
    });

    _syncWithBackend(runs, isWide, isNoBall, isWicket);
  }

  Future<void> _syncWithBackend(int runs, bool isWide, bool isNoBall, bool isWicket) async {
    try {
      await ApiService.addBall({
        "match_id": widget.matchId,
        //"tournament_id": widget.tournamentId,
        "runs": runs,
        "wicket": isWicket,
        "extra_type": isWide ? "wide" : (isNoBall ? "no_ball" : null),
        "extra_runs": (isWide || isNoBall) ? runs : 0, // Sending extra runs
      });
      _fetchLiveScore(silent: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Resyncing..."))
      );
      _fetchLiveScore(); 
    }
  }

  // ==========================================
  // Dialogs & Actions
  // ==========================================
  
  // FIX: Extras Dialog (WD/NB + Runs)
  Future<void> _showExtraRunsDialog(String type) async {
    int? extraRuns = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Runs with ${type == 'WD' ? 'Wide' : 'No Ball'}?"),
        content: Wrap(
          spacing: 10,
          children: [0, 1, 2, 3, 4, 6].map((r) => ElevatedButton(
            onPressed: () => Navigator.pop(context, r),
            child: Text("+$r"),
          )).toList(),
        ),
      )
    );

    if (extraRuns != null) {
      _scoreRun(extraRuns, isWide: type == 'WD', isNoBall: type == 'NB');
    }
  }

  // FIX: Undo Action
  void _undoLastBall() async {
    setState(() => isLoading = true);
    try {
      // NOTE: Call your backend Undo API here if you have one.
      // await ScoringService.undoBall(widget.matchId);
      
      await _fetchLiveScore(); // Refresh state from DB to wipe local mistakes
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reverted to last saved state.")));
    } catch (e) {
      setState(() => isLoading = false);
      print("Undo failed: $e");
    }
  }

  // ==========================================
  // UI Builders
  // ==========================================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String oversDisplay = "${totalBalls ~/ 6}.${totalBalls % 6}";
    double runRate = totalBalls > 0 ? (totalRuns / (totalBalls / 6)) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Live Scoring", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchLiveScore(silent: false),
          )
        ],
      ),
      body: Column(
        children: [
          _buildScoreHeader(oversDisplay, runRate),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildBattingCard(),
                    const SizedBox(height: 8),
                    _buildBowlingCard(),
                    const SizedBox(height: 8),
                    _buildCurrentOverTimeline(),
                  ],
                ),
              ),
            ),
          ),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(String overs, double crr) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade900,
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Column(
        children: [
          const Text("1st Innings", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$totalRuns/$wickets", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                child: Text("($overs)", style: const TextStyle(color: Colors.white70, fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("CRR: ${crr.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 15),
              Text("Extras: $totalExtras", style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBattingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text("Batter", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("R", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("B", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("4s", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("6s", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("SR", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...batsmen.map((b) => _buildPlayerRow(b)).toList(),
          if (batsmen.isEmpty) 
            const Padding(padding: EdgeInsets.all(16), child: Text("Waiting for batsmen selection...")),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(dynamic batter) {
    bool isStriker = batter['is_striker'] == true;
    int r = batter['runs'] ?? 0;
    int b = batter['balls'] ?? 0;
    int fours = batter['fours'] ?? 0; 
    int sixes = batter['sixes'] ?? 0; 
    double sr = b > 0 ? (r / b) * 100 : 0.0;

    return Container(
      color: isStriker ? Colors.green.withOpacity(0.1) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4, 
            child: Text(
              "${batter['name']}${isStriker ? ' *' : ''}", 
              style: TextStyle(
                fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
                color: isStriker ? Colors.green.shade700 : Colors.black87,
                fontSize: 16
              )
            )
          ),
          Expanded(child: Text("$r", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("$b", textAlign: TextAlign.center)),
          Expanded(child: Text("$fours", textAlign: TextAlign.center)),
          Expanded(child: Text("$sixes", textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(sr.toStringAsFixed(1), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildBowlingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text("Bowler", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("O", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("M", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("R", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text("W", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("ER", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(currentBowler['name'], style: const TextStyle(fontSize: 16, color: Colors.black87))),
                Expanded(child: Text(currentBowler['overs'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text("0", textAlign: TextAlign.center)), 
                Expanded(child: Text(currentBowler['runs'].toString(), textAlign: TextAlign.center)),
                Expanded(child: Text(currentBowler['wickets'].toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text(currentBowler['economy'].toString(), textAlign: TextAlign.center)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentOverTimeline() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Text("This Over: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: lastOver.map((ball) => _buildBallCircle(ball)).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBallCircle(String result) {
    Color bgColor = Colors.grey.shade300;
    Color textColor = Colors.black87;

    if (result == "W") { bgColor = Colors.red; textColor = Colors.white; }
    else if (result == "4") { bgColor = Colors.blue; textColor = Colors.white; }
    else if (result == "6") { bgColor = Colors.green; textColor = Colors.white; }
    else if (result.contains("WD") || result.contains("NB")) { bgColor = Colors.orange; textColor = Colors.white; }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(minWidth: 35),
      height: 35,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      alignment: Alignment.center,
      child: Text(result, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn("0", () => _scoreRun(0)),
              _scoreBtn("1", () => _scoreRun(1)),
              _scoreBtn("2", () => _scoreRun(2)),
              _scoreBtn("3", () => _scoreRun(3)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn("4", () => _scoreRun(4), color: Colors.blue, textColor: Colors.white),
              _scoreBtn("6", () => _scoreRun(6), color: Colors.green, textColor: Colors.white),
              // FIX: Now opens extra run dialog
              _scoreBtn("WD", () => _showExtraRunsDialog('WD'), color: Colors.orange.shade100, textColor: Colors.orange.shade900),
              _scoreBtn("NB", () => _showExtraRunsDialog('NB'), color: Colors.orange.shade100, textColor: Colors.orange.shade900),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn("OUT", () => _scoreRun(0, isWicket: true), color: Colors.red, textColor: Colors.white),
              _scoreBtn("BYE", () => {}, color: Colors.grey.shade200),
              _scoreBtn("LB", () => {}, color: Colors.grey.shade200), 
              // FIX: Wired up the Undo button
              _scoreBtn("UNDO", _undoLastBall, color: Colors.grey.shade300, icon: Icons.undo), 
            ],
          )
        ],
      ),
    );
  }

  Widget _scoreBtn(String text, VoidCallback onTap, {Color? color, Color? textColor, IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: color ?? Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: icon != null 
                ? Icon(icon, color: Colors.black54)
                : Text(text, style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: textColor ?? Colors.blue.shade900
                  )),
          ),
        ),
      ),
    );
  }
}