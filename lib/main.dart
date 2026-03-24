import 'package:flutter/material.dart';

import 'auth/forgot_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/otp_screen.dart';
import 'auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      initialRoute: "/login",

      routes: {

        "/login": (context) => const LoginScreen(),

        "/register": (context) => const RegisterFlow(),

        "/otp": (context) => const OtpScreen(),

        "/forgot": (context) => const ForgotPasswordScreen(),

       "/home": (context) => DashboardScreen(),

      },
    );
  }
}