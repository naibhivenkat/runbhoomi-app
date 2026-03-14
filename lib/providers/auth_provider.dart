
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

  String? token;

  void setToken(String t){
    token=t;
    notifyListeners();
  }

}
