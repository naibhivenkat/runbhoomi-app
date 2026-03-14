
import '../core/api_client.dart';

class AuthService {

  static Future login(String email,String password) async {

    return await ApiClient.post(
      "/auth/login",
      {
        "email":email,
        "password":password
      }
    );

  }

}
