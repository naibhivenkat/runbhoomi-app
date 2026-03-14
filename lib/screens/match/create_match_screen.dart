
import 'package:flutter/material.dart';
import '../../services/match_service.dart';

class CreateMatchScreen extends StatelessWidget {

  createMatch() async {

    var res = await MatchService.createMatch(1,2,20);

    print(res);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: Text("Create Match")),
      body: Center(
        child: ElevatedButton(
          onPressed: createMatch,
          child: Text("Start Match"),
        ),
      ),
    );

  }

}
