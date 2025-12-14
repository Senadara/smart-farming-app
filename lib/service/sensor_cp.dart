import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SensorService {
  // Gunakan getter untuk menghindari masalah null
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null) {
      throw Exception("BASE_URL is not set in .env");
    }
    return '$url/sensors/latest';
  }

  // Static method
  static Future<Map<String, dynamic>> getLatestSensor(String token) async {
    final uri = Uri.parse(baseUrl);

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body["data"] as Map<String, dynamic>;
    } else {
      throw Exception(
          "Failed to fetch sensor data: ${response.statusCode} - ${response.body}");
    }
  }
}