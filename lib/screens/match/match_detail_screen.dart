import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {

  const MatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Match Details")),
      body: const Center(
        child: Text("Match Info"),
      ),
    );

  }
}