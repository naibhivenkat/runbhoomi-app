import 'package:flutter/material.dart';

class TeamDetailScreen extends StatelessWidget {

  const TeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Team Details")),
      body: const Center(
        child: Text("Team Info"),
      ),
    );

  }
}