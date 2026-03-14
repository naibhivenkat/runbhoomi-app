
import 'package:flutter/material.dart';

class MatchProvider extends ChangeNotifier {

  int runs=0;
  int wickets=0;

  void addRuns(int r){
    runs+=r;
    notifyListeners();
  }

}
