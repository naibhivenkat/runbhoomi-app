// import 'package:flutter/material.dart';

// import 'auth/forgot_password_screen.dart';
// import 'auth/login_screen.dart';
// import 'auth/otp_screen.dart';
// import 'auth/register_screen.dart';

// import 'screens/dashboard/dashboard_screen.dart';

// import 'screens/match/match_detail_screen.dart';


// import 'screens/onboarding/sport_selection_screen.dart';

// import 'screens/profile/edit_profile_screen.dart';
// import 'screens/profile/profile_screen.dart';

// import 'screens/splash/splash_screen.dart';

// import 'screens/teams/team_detail_screen.dart';
// import 'screens/teams/team_list_screen.dart';
// import 'services/api_service.dart';
// import 'services/session_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   /// 🔥 GLOBAL ERROR LOGGER (VERY IMPORTANT)
//   FlutterError.onError = (FlutterErrorDetails details) {
//     debugPrint("🔥🔥 FLUTTER ERROR START 🔥🔥");
//     debugPrint(details.exceptionAsString());
//     debugPrint(details.stack.toString());
//     debugPrint("🔥🔥 FLUTTER ERROR END 🔥🔥");
//   };

//   /// 🔥 LOAD SAVED USER
//   final token = await SessionService.getToken();

//   if (token != null) {
//     ApiService.token = token;
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       /// ✅ START SCREEN
//       initialRoute: "/splash",

//       /// ✅ STATIC ROUTES
//       routes: {
//         "/splash": (context) => const SplashScreen(),
//         "/register": (context) => const RegisterFlow(),
//         "/otp": (context) => const OtpScreen(),
//         "/forgot": (context) => const ForgotPasswordScreen(),
//         "/home": (context) => const DashboardScreen(),

//         "/sport-selection": (context) => const SportSelectionScreen(),
//         "/profile": (context) => const ProfileScreen(),
//         "/edit-profile": (context) => const EditProfileScreen(),

//         "/teams": (context) => const TeamListScreen(),
//         "/team-details": (context) => const TeamDetailScreen(),
//       },

//       /// 🔥 DYNAMIC ROUTES
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case "/match-details":
//             final args = settings.arguments as Map<String, dynamic>;

//             return MaterialPageRoute(
//               builder: (_) => MatchDetailScreen(
//                 matchId: args["matchId"],
//               ),
//             );

//           default:
//             return null;
//         }
//       },

//       /// ❌ FALLBACK
//       onUnknownRoute: (settings) {
//         debugPrint("❌ UNKNOWN ROUTE: ${settings.name}");
//         return MaterialPageRoute(
//           builder: (_) => const LoginScreen(),
//         );
//       },
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Import your Isar models
import 'models/tournament_model.dart';
import 'models/sync_action_model.dart';

import 'auth/forgot_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/otp_screen.dart';
import 'auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/match/match_detail_screen.dart';
import 'screens/onboarding/sport_selection_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/teams/team_detail_screen.dart';
import 'screens/teams/team_list_screen.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

/// 🔥 GLOBAL ISAR INSTANCE
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 GLOBAL ERROR LOGGER
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint("🔥🔥 FLUTTER ERROR START 🔥🔥");
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack.toString());
    debugPrint("🔥🔥 FLUTTER ERROR END 🔥🔥");
  };

  /// 🔥 INITIALIZE ISAR DATABASE (NEW)
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [TournamentSchema, SyncActionSchema],
    directory: dir.path,
  );

  /// 🔥 LOAD SAVED USER
  final token = await SessionService.getToken();
  if (token != null) {
    ApiService.token = token;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/register": (context) => const RegisterFlow(),
        "/otp": (context) => const OtpScreen(),
        "/forgot": (context) => const ForgotPasswordScreen(),
        "/home": (context) => const DashboardScreen(),
        "/sport-selection": (context) => const SportSelectionScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/edit-profile": (context) => const EditProfileScreen(),
        "/teams": (context) => const TeamListScreen(),
        "/team-details": (context) => const TeamDetailScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
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
      onUnknownRoute: (settings) {
        debugPrint("❌ UNKNOWN ROUTE: ${settings.name}");
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}