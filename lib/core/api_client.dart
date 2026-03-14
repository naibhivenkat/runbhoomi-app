
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {

  static const baseUrl = "http://YOUR_SERVER_IP:8000";

  static Future<dynamic> post(String endpoint, Map data) async {

    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

}
