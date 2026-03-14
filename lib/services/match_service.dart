
import '../core/api_client.dart';

class MatchService {

  static Future createMatch(int team1,int team2,int overs) async {

    return await ApiClient.post(
      "/matches/create",
      {
        "team1":team1,
        "team2":team2,
        "overs":overs
      }
    );

  }

}
