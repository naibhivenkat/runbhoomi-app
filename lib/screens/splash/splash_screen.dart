import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../services/session_service.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> scaleAnim;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _navigate();
  }

Future<void> _navigate() async {
  await Future.delayed(const Duration(seconds: 2));

  final isLoggedIn = await SessionService.isLoggedIn();

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => isLoggedIn
          ? const DashboardScreen()
          : const LoginScreen(),
    ),
  );
}

  @override
  void dispose() {
    _controller.dispose();
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

        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {

              return Opacity(
                opacity: fadeAnim.value,
                child: Transform.scale(
                  scale: scaleAnim.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [

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
              );
            },
          ),
        ),
      ),
    );
  }
}