
import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {

  final String name;

  PlayerCard({required this.name});

  @override
  Widget build(BuildContext context){

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(name),
      ),
    );

  }

}
