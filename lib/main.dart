// import 'package:flutter/material.dart';

// import 'auth/forgot_password_screen.dart';
// import 'auth/login_screen.dart';
// import 'auth/otp_screen.dart';
// import 'auth/register_screen.dart';
// import 'screens/dashboard/dashboard_screen.dart';
// import 'screens/match/create_match_screen.dart';
// import 'screens/match/match_detail_screen.dart';
// import 'screens/match/match_list_screen.dart';
// import 'screens/onboarding/sport_selection_screen.dart';
// import 'screens/profile/edit_profile_screen.dart';
// import 'screens/profile/profile_screen.dart';
// import 'screens/splash/splash_screen.dart';
// import 'screens/teams/team_detail_screen.dart';
// import 'screens/teams/team_list_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       // ✅ ALWAYS START FROM SPLASH
//       initialRoute: "/splash",

//       routes: {
//         "/splash": (context) => const SplashScreen(), 
//         "/register": (context) => const RegisterFlow(),
//         "/otp": (context) => const OtpScreen(),
//         "/forgot": (context) => const ForgotPasswordScreen(),
//         "/home": (context) => const DashboardScreen(),

//         "/sport-selection": (context) => const SportSelectionScreen(),
//         "/profile": (context) => const ProfileScreen(),
//         "/edit-profile": (context) => const EditProfileScreen(),

//         "/matches": (context) => const MatchListScreen(),
//         "/match-details": (context) => const MatchDetailScreen(),
//         "/create-match": (context) => const CreateMatchScreen(),

//         "/teams": (context) => const TeamListScreen(),
//         "/team-details": (context) => const TeamDetailScreen(),
//       },

//       onUnknownRoute: (settings) {
//         print("❌ UNKNOWN ROUTE: ${settings.name}");
//         return MaterialPageRoute(
//           builder: (_) => const LoginScreen(),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'auth/forgot_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/otp_screen.dart';
import 'auth/register_screen.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/match/create_match_screen.dart';
import 'screens/match/match_detail_screen.dart';
import 'screens/match/match_list_screen.dart';

import 'screens/onboarding/sport_selection_screen.dart';

import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';

import 'screens/splash/splash_screen.dart';

import 'screens/teams/team_detail_screen.dart';
import 'screens/teams/team_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ✅ START SCREEN
      initialRoute: "/splash",

      /// ✅ STATIC ROUTES (NO PARAMS)
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/register": (context) => const RegisterFlow(),
        "/otp": (context) => const OtpScreen(),
        "/forgot": (context) => const ForgotPasswordScreen(),
        "/home": (context) => const DashboardScreen(),

        "/sport-selection": (context) => const SportSelectionScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/edit-profile": (context) => const EditProfileScreen(),

        "/matches": (context) => const MatchListScreen(),
        "/create-match": (context) => const CreateMatchScreen(),

        "/teams": (context) => const TeamListScreen(),
        "/team-details": (context) => const TeamDetailScreen(),
      },

   
      onGenerateRoute: (settings) {
        switch (settings.name) {

          /// 🔥 MATCH DETAILS (WITH ID)
          case "/match-details":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => MatchDetailScreen(
                matchId: args["matchId"],
              ),
            );

          default:
            return null;
        }
      },

      /// ❌ FALLBACK ROUTE
      onUnknownRoute: (settings) {
        debugPrint("❌ UNKNOWN ROUTE: ${settings.name}");
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}