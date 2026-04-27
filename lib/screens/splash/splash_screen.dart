import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../services/session_service.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Timer? _navTimer; // ✅ track timer
  bool _disposed = false; // ✅ lifecycle guard

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  void _startNavigation() {
    _navTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted || _disposed) return;

      final isLoggedIn = await SessionService.isLoggedIn();

      if (!mounted || _disposed) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? const DashboardScreen()
              : const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _disposed = true;

    _navTimer?.cancel(); // ✅ cancel timer

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_cricket,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                "RunBhoomi",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Cricket Starts Here",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}