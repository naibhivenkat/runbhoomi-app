import 'package:flutter/material.dart';

class MyCricketScreen extends StatefulWidget {
  const MyCricketScreen({super.key});

  @override
  State<MyCricketScreen> createState() => _MyCricketScreenState();
}

class _MyCricketScreenState extends State<MyCricketScreen> {
  bool isLoading = true;
  Map<String, dynamic>? profile;
  List<dynamic> matches = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));

    // 🔥 MOCK DATA → replace with API
    profile = {
      "name": "Ravi Kumar",
      "role": "All-rounder",
      "matches": 24,
      "runs": 820,
      "wickets": 18,
      "avg": 34.2,
      "strike": 128.5,
    };

    matches = [
      {"vs": "MI", "runs": 45, "wickets": 2, "result": "W"},
      {"vs": "RCB", "runs": 12, "wickets": 0, "result": "L"},
      {"vs": "CSK", "runs": 78, "wickets": 1, "result": "W"},
    ];

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _Loading();

    if (profile == null) {
      return const Center(child: Text("No Data Found"));
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(profile: profile!),
          const SizedBox(height: 20),

          const Text("Performance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _StatsGrid(profile: profile!),

          const SizedBox(height: 20),

          const Text("Recent Matches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...matches.map((m) => _MatchTile(match: m)),
        ],
      ),
    );
  }
}

// ---------------- PROFILE CARD ----------------
class _ProfileCard extends StatelessWidget {
  final Map profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(profile['role'],
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text("Matches: ${profile['matches']}",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------------- STATS GRID ----------------
class _StatsGrid extends StatelessWidget {
  final Map profile;
  const _StatsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _stat("Runs", profile['runs'].toString()),
        _stat("Wickets", profile['wickets'].toString()),
        _stat("Average", profile['avg'].toString()),
        _stat("Strike Rate", profile['strike'].toString()),
      ],
    );
  }

  Widget _stat(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ---------------- MATCH TILE ----------------
class _MatchTile extends StatelessWidget {
  final Map match;
  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final isWin = match['result'] == 'W';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isWin ? Colors.green : Colors.red,
            child: Text(match['result'],
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("vs ${match['vs']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    "${match['runs']} runs • ${match['wickets']} wickets",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16)
        ],
      ),
    );
  }
}

// ---------------- LOADING ----------------
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
