import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {

  final String sport;
  final String location;
  final String date;

  const MatchCard({
    super.key,
    required this.sport,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text(sport),
        subtitle: Text("$location • $date"),
      ),
    );

  }
}