import 'package:flutter/material.dart';

class SquadsTab extends StatelessWidget {
  final int matchId;

  const SquadsTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Squads (API)",
          style: TextStyle(color: Colors.white)),
    );
  }
}