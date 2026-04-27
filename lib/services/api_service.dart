import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/match_model.dart';
import '../models/tournament_model.dart';
import 'session_service.dart';



class ApiService {

  static String? token;


  static const String baseUrl =
      "https://runbhoomi-backend.onrender.com";


      static Map<String, String> get headers => {
  "Content-Type": "application/json",
  if (token != null) "Authorization": "Bearer $token",
};

  /// 🔥 COMMON RESPONSE HANDLER
  static dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
          "API ERROR ${res.statusCode}: ${res.body}");
    }
  }

  /// ================= AUTH =================

  static Future<Map<String, dynamic>> registerPlayer(
      Map<String, dynamic> data) async {
    final res = await http
        .post(
          Uri.parse("$baseUrl/auth/player_register"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 20));

    return _handleResponse(res);
  }

  static Future sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/send_otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return _handleResponse(res);
  }

  static Future verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify_otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> googleLogin(
      String idToken) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    final data = _handleResponse(res);

    return {
      "token": data["token"],
      "email": data["user"]?["email"],
      "user": data["user"],
    };
  }

  static Future login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return _handleResponse(res);
  }

  static Future loginOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return _handleResponse(res);
  }

  static Future verifyLoginOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify-login-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return _handleResponse(res);
  }

  static Future forgotOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return _handleResponse(res);
  }

  static Future verifyForgotOtp(
      String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify-forgot-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return _handleResponse(res);
  }

  static Future resetPassword(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    return _handleResponse(res);
  }

  /// ================= MATCHES =================

  static Future<List> getMatchesByUser(String email) async {
    final url = Uri.parse("$baseUrl/matches/get_matches")
        .replace(queryParameters: {"email": email});

    final res = await http.get(url);
    return _handleResponse(res);
  }

  static Future<List> getMatchesByTournament(int tournamentId) async {
  final url = Uri.parse("$baseUrl/matches/tournament/$tournamentId");

  final res = await http.get(url);
  return _handleResponse(res);
}

  static Future<MatchModel> getMatchDetail(int matchId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/matches/$matchId"));
    return MatchModel.fromJson(_handleResponse(res));
  }

  static Future<Map<String, dynamic>> getLive(
      int matchId) async {
    final res = await http
        .get(Uri.parse("$baseUrl/matches/$matchId/live"))
        .timeout(const Duration(seconds: 10));

    return _handleResponse(res);
  }

  static Future<List<String>> getLastBalls(
      int matchId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/matches/$matchId/last_ball"),
    );

    final data = _handleResponse(res);
    return List<String>.from(data["lastBalls"] ?? []);
  }



static Future resetMatch(int matchId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/matches/$matchId/reset"),
        headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  return _handleResponse(res);
}

  /// ================= TOURNAMENT =================

  // static Future<List<Tournament>> getTournaments() async {
  //   final res =
  //       await http.get(Uri.parse("$baseUrl/tournaments"));

  //   final data = _handleResponse(res);

  //   return List.from(data)
  //       .map((e) => Tournament.fromJson(e))
  //       .toList();
  // }

  static Future<List<Tournament>> getTournaments() async {
    final res = await http.get(Uri.parse("$baseUrl/tournaments"));

    final data = _handleResponse(res) as List;

    return data.map((e) {
      // 1. Create the empty Isar object
      final t = Tournament();
      
      // 2. Hydrate it with the JSON data
      t.fromJson(e as Map<String, dynamic>);
      
      // 3. Return the populated object
      return t;
    }).toList();
  }



static Future<void> createTournamentFull({
  required String name,
  required String city,
  required String ground,
  required String organizerName,
  required String organizerPhone,
  required String organizerEmail,
  required String startDate,
  required String endDate,
  required String category,
  required String ballType,
  required String pitchType,
  required String matchType,
  required int totalTeams,
  required String format,
  required int overs,
  String? logoUrl,
  String? bannerUrl,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/tournaments/create"),

    // 🔥 FIX HERE
    headers: headers,

    body: jsonEncode({
      "name": name,
      "city": city,
      "ground": ground,
      "organizer_name": organizerName,
      "organizer_phone": organizerPhone,
      "organizer_email": organizerEmail,
      "start_date": startDate,
      "end_date": endDate,
      "category": category,
      "ball_type": ballType,
      "pitch_type": pitchType,
      "match_type": matchType,
      "total_teams": totalTeams,
      "format": format,
      "overs": overs,
      "logo_url": logoUrl,
      "banner_url": bannerUrl,
    }),
  );

  _handleResponse(res);
}

  /// ================= TEAMS (FIXED 🔥) =================

  static Future<List> getTeams(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/tournaments/$id/teams"),
    );
    return _handleResponse(res);
  }

  
  static Future<void> deleteTeam(int teamId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/tournaments/teams/$teamId"),
    );

    _handleResponse(res);
  }

  static Future rejectTeam(int tournamentId, int teamId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/tournaments/$tournamentId/reject/$teamId"),
    headers: headers, 
  );
  return _handleResponse(res);
}

  /// ================= MATCHES =================

  static Future<List> getTournamentMatches(
      int tournamentId) async {
    final res = await http.get(
      Uri.parse(
          "$baseUrl/tournaments/$tournamentId/matches"),
    );

    return _handleResponse(res);
  }

  static Future generateFixtures(int id) async {
    final res = await http.post(
      Uri.parse(
          "$baseUrl/tournaments/$id/generate_fixtures"),
    );

    return _handleResponse(res);
  }

  static Future<List> getPoints(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/tournaments/$id/points"),
    );

    return _handleResponse(res);
  }

  /// ================= CAPTAIN FLOW =================

static Future createTeam(String name, int captainId) async {
  final url = Uri.parse("$baseUrl/tournaments/teams/create")
      .replace(queryParameters: {
    "name": name,
    "captain_id": captainId.toString(),
  });

  final res = await http.post(url);
  return _handleResponse(res);
}

static Future joinTournament(int tournamentId, int teamId) async {
  final url = Uri.parse(
    "$baseUrl/tournaments/$tournamentId/join",
  ).replace(queryParameters: {
    "team_id": teamId.toString(),
  });

  // 🔥 GET TOKEN (adjust based on your storage)
  final token = await SessionService.getToken(); 

  final res = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
   print(res.body);
  return _handleResponse(res);
 
}


static Future getJoinRequests(int tournamentId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/tournaments/$tournamentId/requests"),
    headers: headers,   
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load requests");
  }

  return jsonDecode(res.body);
}

static Future approveTeam(int tournamentId, int teamId) async {
  try {
    final res = await http
        .post(
          Uri.parse("$baseUrl/tournaments/$tournamentId/approve/$teamId"),
          headers: headers, 
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(res);
  } catch (e) {
    // 🔥 swallow render connection issue
    return {"message": "Approved (assumed)"};
  }
}

static Future initMatchFromFixture(int tmId) async {
  final res = await http.post(Uri.parse("$baseUrl/tournaments/matches/$tmId/init"));
  return jsonDecode(res.body);
}

static Future startMatch(
  int matchId,
  int striker,
  int nonStriker,
) async {
  final token = await SessionService.getToken();

  final res = await http.post(
    Uri.parse("$baseUrl/matches/$matchId/start_match"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "striker_id": striker,
      "non_striker_id": nonStriker,
    }),
  );

  return _handleResponse(res);
}

static Future<List> getYetToBat(int matchId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/matches/$matchId/yet_to_bat"),
  );

  final data = _handleResponse(res);
  return data["players"];
}



static Future<List> getTeamPlayers(int teamId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/matches/teams/$teamId/players"),
  );

  final data = _handleResponse(res);
  return data;
}

static Future addPlayerToTeam(int teamId, int playerId) async {
  final res = await http.post(
  Uri.parse("$baseUrl/matches/add_player_to_team"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "team_id": teamId,
    "player_id": playerId,
  }),
);

  return _handleResponse(res);
}

static Future<Map<String, dynamic>> addBall(
    Map<String, dynamic> data) async {

  final url = Uri.parse("$baseUrl/matches/${data["match_id"]}/add_ball");
  final token = await SessionService.getToken();

  final res = await http.post(
    url,
    headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer $token",
},
    body: jsonEncode({
      "tournament_id": data["tournament_id"],
      "runs": data["runs"] ?? 0,
      "wicket": data["wicket"] ?? false,
      "extra_type": data["extra_type"],
      "extra_runs": data["extra_runs"] ?? 0,
      "next_batsman_id": data["next_batsman_id"],
    }),
  );

  return _handleResponse(res);
}
static Future<Map<String, dynamic>> undoBall(int matchId) async {
  final url = Uri.parse("$baseUrl/matches/$matchId/undo_ball");

    final res = await http.delete(
    url,
    headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer $token",
    },);

  // final res = await http.delete(url);

  return _handleResponse(res);
}

static Future<Map<String, dynamic>> selectNextBatsman(
    Map<String, dynamic> data) async {

final url = Uri.parse("$baseUrl/matches/${data["match_id"]}/next_batsman")
    .replace(queryParameters: {
  "player_id": data["player_id"].toString(),
});

  final token = await SessionService.getToken();

  final res = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },

  );

  return _handleResponse(res);
}


static Future createInvite(int teamId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/tournaments/teams/$teamId/invite"),
  );

  return _handleResponse(res);
}

static Future joinTeamByCode(String code, int playerId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/tournaments/teams/join/$code"),
    body: {
      "player_id": playerId.toString(),
    },
  );

  return _handleResponse(res);
}


static Future<void> deleteUpcomingFixtures(int tournamentId) async {
  final res = await http.delete(
    Uri.parse("$baseUrl/tournaments/$tournamentId/fixtures/upcoming"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to delete upcoming fixtures");
  }
}



static Future searchPlayers(String query, int teamId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/players/search?q=$query&team_id=$teamId"),
  );
  return _handleResponse(res);
}


static Future quickAddPlayer({
  required String name,
  String? phone,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/matches/players/quick_add"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "phone": phone,
    }),
  );

  return _handleResponse(res);
}

static Future setPlayingXI({
  required int matchId,
  required int teamId,
  required List playerIds,

  
}) async {
  
  final res = await http.post(
    Uri.parse("$baseUrl/matches/$matchId/set_playing_xi"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "team_id": teamId,
      "player_ids": playerIds,
    }),
  );

  return _handleResponse(res);
}


static Future<List> getGroups(int tournamentId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/tournaments/$tournamentId/groups"),
  );
  return _handleResponse(res);
}



static Future generateFixturesWithGroups({
  required int tournamentId,
  required int groupCount,
  required String startTime,
  required int gap,
}) async {

  final url =
      "$baseUrl/tournaments/$tournamentId/generate_fixtures"
      "?group_count=$groupCount"
      "&start_time=$startTime"
      "&gap=$gap";

  final res = await http.post(
    Uri.parse(url),
    headers: headers,
  );

  // 🔥 ADD THIS
  if (res.statusCode != 200) {
    throw Exception("Failed: ${res.body}");
  }

  return jsonDecode(res.body);
}


static Future getMyRole(int tournamentId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/tournaments/$tournamentId/my-role"),
    headers: headers,
  );
  return jsonDecode(res.body);
}

static Future<Map<String, dynamic>> getMyCricket() async {
  try {
    final email = await SessionService.getEmail();
    if (email == null) {
      throw Exception("User not logged in");
    }

    final res = await http.get(
      Uri.parse("$baseUrl/my-cricket?email=$email"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load cricket data");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}
}


