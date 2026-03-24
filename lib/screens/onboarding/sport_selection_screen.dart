import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class SportSelectionScreen extends StatelessWidget {

  const SportSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Select Sport")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
          child: const Text("Continue"),
        ),
      ),
    );

  }
}