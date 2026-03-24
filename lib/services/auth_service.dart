import '../core/api_client.dart';

class AuthService {

  static Future login(String email, String password) async {

    final res = await ApiClient.post(
      "/auth/login",
      {
        "email": email,
        "password": password
      },
    );

    return res;
  }

  static Future register(
      String name,
      String email,
      String password
      ) async {

    final res = await ApiClient.post(
      "/auth/register",
      {
        "name": name,
        "email": email,
        "password": password
      },
    );

    return res;
  }

}