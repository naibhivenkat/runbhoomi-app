import 'package:flutter/material.dart';

class CommentaryTab extends StatelessWidget {
  final int matchId;

  const CommentaryTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Commentary (API)",
          style: TextStyle(color: Colors.white)),
    );
  }
}