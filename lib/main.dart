
import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(RunBhoomiApp());
}

class RunBhoomiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunBhoomi',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
    );
  }
}
