import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // static Future<void> saveUser(String email, String token, {int? userId}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("email", email);
  //   await prefs.setString("token", token);

  //   // ✅ NEW (optional, won't break existing calls)
  //   if (userId != null) {
  //     await prefs.setInt("user_id", userId);
  //   }
  // }

  static Future<void> saveUser(String email, String token, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
    await prefs.setString("token", token);

    // ✅ Now perfectly handles the new UUID Strings!
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString("user_id", userId); 
    }
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ✅ NEW METHOD (non-breaking)
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }
}