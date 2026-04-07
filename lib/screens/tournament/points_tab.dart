import 'package:flutter/material.dart';

class PointsTab extends StatelessWidget {
  final int tournamentId;

  PointsTab({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Points Table API here for ID: $tournamentId"));
  }
}
