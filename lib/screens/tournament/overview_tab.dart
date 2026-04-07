import 'package:flutter/material.dart';
import '../../../models/tournament_model.dart';

class OverviewTab extends StatelessWidget {
  final Tournament tournament;

  OverviewTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${tournament.name}"),
          Text("Location: ${tournament.location}"),
          Text("Type: ${tournament.type}"),
        ],
      ),
    );
  }
}