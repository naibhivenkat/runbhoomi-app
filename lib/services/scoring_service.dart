
import '../core/api_client.dart';

class ScoringService {

  static Future addBall(int matchId,int over,int ball,int runs) async {

    return await ApiClient.post(
      "/scoring/ball",
      {
        "match_id":matchId,
        "over":over,
        "ball":ball,
        "runs":runs
      }
    );

  }

}
