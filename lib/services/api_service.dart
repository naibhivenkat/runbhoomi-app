import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  static const String baseUrl = "https://runbhoomi-backend.onrender.com";

  static Future<Map<String, dynamic>> registerPlayer(
      Map<String, dynamic> data) async {

    final url = Uri.parse("$baseUrl/auth/player_register");
    try {

      final res = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        throw Exception(
            "API ERROR ${res.statusCode}: ${res.body}");
      }

    } catch (e) {
      rethrow;
    }
  }


  static Future sendOtp(String email) async {

    var res = await http.post(
      Uri.parse("$baseUrl/auth/send_otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return jsonDecode(res.body);
  }

  static Future verifyOtp(String email, String otp) async {

    var res = await http.post(
      Uri.parse("$baseUrl/auth/verify_otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp
      }),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
  final url = Uri.parse("$baseUrl/auth/google");

  try {
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idToken": idToken,
      }),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Google Login Failed: ${res.body}");
    }
  } catch (e) {
    rethrow;
  }
} 

static Future login(String email, String password) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password
    }),
  );

  return jsonDecode(res.body);
}

static Future loginOtp(String email) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/login-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  return jsonDecode(res.body);
}
static Future verifyLoginOtp(String email, String otp) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/verify-login-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp
    }),
  );

  return jsonDecode(res.body);
}


static Future forgotOtp(String email) async {
  return http.post(
    Uri.parse("$baseUrl/auth/forgot-password-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );
}
static Future verifyForgotOtp(String email, String otp) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/verify-forgot-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp
    }),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    final data = jsonDecode(res.body);
    throw Exception(data["detail"] ?? "OTP failed");
  }
}

static Future resetPassword(String email, String password) async {
  return http.post(
    Uri.parse("$baseUrl/auth/reset-password"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password
    }),
  );
}

}