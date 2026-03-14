
import 'package:flutter/material.dart';
import '../../services/scoring_service.dart';

class ScoringScreen extends StatelessWidget {

  addRun(int r) async {

    var res = await ScoringService.addBall(1,1,1,r);

    print(res);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: Text("Scoring")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          ElevatedButton(onPressed: ()=>addRun(1),child: Text("1")),
          ElevatedButton(onPressed: ()=>addRun(2),child: Text("2")),
          ElevatedButton(onPressed: ()=>addRun(4),child: Text("4")),
          ElevatedButton(onPressed: ()=>addRun(6),child: Text("6")),

        ],
      ),
    );

  }

}
