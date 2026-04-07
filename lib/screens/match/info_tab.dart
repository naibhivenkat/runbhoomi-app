import 'package:flutter/material.dart';
import '../../../models/match_model.dart';

class InfoTab extends StatelessWidget {
  final MatchModel match;

  const InfoTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _tile("Match", "${match.team1} vs ${match.team2}"),
        _tile("Status", match.status),
      ],
    );
  }

  Widget _tile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      trailing: Text(value,
          style: const TextStyle(color: Colors.white)),
    );
  }
}