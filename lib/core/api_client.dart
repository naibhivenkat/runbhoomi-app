import 'dart:convert';
import 'package:http/http.dart' as http;

import 'secure_storage.dart';

class ApiClient {

  static const baseUrl = "https://runbhoomi-backend.onrender.com";

  static Future post(String path, Map data) async {

    final token = await SecureStorage.getToken();

    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

}
