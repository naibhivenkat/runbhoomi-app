import 'package:flutter/material.dart';
import '../../widgets/match_card.dart';

class MatchListScreen extends StatelessWidget {

  const MatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Matches")),

      body: ListView(
        children: const [

          MatchCard(
            sport: "Cricket",
            location: "Chikmagalur",
            date: "Tomorrow",
          ),

        ],
      ),
    );

  }
}