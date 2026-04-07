import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../uttls/community_screen.dart';
import '../../uttls/looking_screen.dart';
import '../home/home_screen.dart';
import '../profile/my_cricket_screen.dart';
import '../tournament/tournament_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = const [
      HomeScreen(),
      LookingScreen(),
      MyCricketScreen(),
      CommunityScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),

      /// 🔝 PREMIUM APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.sports_cricket, color: Colors.green),
            SizedBox(width: 8),
            Text(
              "RunBhoomi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          _iconBtn(Icons.location_on_outlined),
          _iconBtn(Icons.filter_alt_outlined),
          Stack(
            children: [
              _iconBtn(Icons.message_outlined),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),

      /// 🔥 SCREEN SWITCH (SMOOTH)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_currentIndex],
      ),

      /// 🔥 SMART FAB (ONLY WHERE NEEDED)
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: (_currentIndex == 1 || _currentIndex == 3)
            ? FloatingActionButton.extended(
                key: ValueKey(_currentIndex),
                backgroundColor: Colors.green,
                onPressed: () {
                  _showPostOptions(context);
                },
                icon: const Icon(Icons.add),
                label: const Text("Post"),
              )
            : const SizedBox.shrink(),
      ),

      /// 🔻 PREMIUM BOTTOM NAV
      bottomNavigationBar: _premiumBottomBar(),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 ICON BUTTON
  ////////////////////////////////////////////////////////////

  Widget _iconBtn(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.black87),
      onPressed: () {},
    );
  }

  ////////////////////////////////////////////////////////////
  /// 💎 PREMIUM BOTTOM NAV
  ////////////////////////////////////////////////////////////

  Widget _premiumBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Looking"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_cricket), label: "My Cricket"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Community"),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🚀 POST OPTIONS (BOTTOM SHEET)
  ////////////////////////////////////////////////////////////

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              _postTile(Icons.sports_cricket, "Create Match"),
              _postTile(Icons.group, "Looking for Players"),
              _postTile(Icons.post_add, "Create Post"),

            ],
          ),
        );
      },
    );
  }

  Widget _postTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {},
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 DRAWER
////////////////////////////////////////////////////////////

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 30, child: Icon(Icons.person)),
                SizedBox(height: 10),
                Text(
                  "Player Name",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "+91 9876543210",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const ListTile(
              leading: Icon(Icons.person), title: Text("Profile")),

          ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.orange),
                title: const Text("Tournaments"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentListScreen(),
                    ),
                  );
                },
              ),

          const ListTile(
              leading: Icon(Icons.settings), title: Text("Settings")),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await SessionService.clear();

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}