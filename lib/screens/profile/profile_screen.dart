import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.editProfile);
          },
          child: const Text("Edit Profile"),
        ),
      ),
    );

  }
}