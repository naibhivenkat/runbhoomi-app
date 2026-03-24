import 'package:flutter/material.dart';

import '../match/create_match_screen.dart';
import '../match/match_list_screen.dart';
import '../teams/team_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  int index = 0;

  final pages = [
    const MatchListScreen(),
    const CreateMatchScreen(),
    const TeamListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: index,

        onTap: (i) {
          setState(() {
            index = i;
          });
        },

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.sports_cricket),
              label: "Matches"),

          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Create"),

          BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: "Teams"),

          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"),

        ],
      ),
    );

  }
}