
import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {

  final int runs;
  final int wickets;

  ScoreWidget({required this.runs,required this.wickets});

  @override
  Widget build(BuildContext context){

    return Text("$runs / $wickets",
      style: TextStyle(fontSize:32,fontWeight:FontWeight.bold));

  }

}
