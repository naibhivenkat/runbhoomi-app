import 'package:flutter/material.dart';

class StatsTab extends StatelessWidget {
  final int matchId;

  const StatsTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Stats + Graphs (API)",
          style: TextStyle(color: Colors.white)),
    );
  }
}