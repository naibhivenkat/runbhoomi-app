import 'package:flutter/material.dart';

class TeamListScreen extends StatelessWidget {

  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Teams")),
      body: const Center(
        child: Text("Team List"),
      ),
    );

  }
}