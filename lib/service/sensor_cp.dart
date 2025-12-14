// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class SensorService {
//   // Gunakan getter untuk menghindari masalah null
//   static String get baseUrl {
//     final url = dotenv.env['BASE_URL'];
//     if (url == null) {
//       throw Exception("BASE_URL is not set in .env");
//     }
//     return '$url/sensors/latest';
//   }

//   // Static method
//   static Future<Map<String, dynamic>> getLatestSensor(String token) async {
//     final uri = Uri.parse(baseUrl);

//     final response = await http.get(
//       uri,
//       headers: {
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       },
//     );

//     if (response.statusCode == 200) {
//       final body = jsonDecode(response.body) as Map<String, dynamic>;
//       return body["data"] as Map<String, dynamic>;
//     } else {
//       throw Exception(
//           "Failed to fetch sensor data: ${response.statusCode} - ${response.body}");
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class SensorService {
  // ===============================
  // 🔑 TAMBAHAN: AuthService
  // ===============================
  final AuthService _authService = AuthService();

  // ===============================
  // 🌐 BASE URL (aman dari null)
  // ===============================
  String get _baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("BASE_URL is not set in .env");
    }
    return '$url/melon/latest';
  }

  // ===============================
  // 📡 GET SENSOR TERBARU (AUTO TOKEN)
  // ===============================
  Future<Map<String, dynamic>> getLatestSensor() async {
    // 🔑 Ambil token otomatis dari login
    final resolvedToken = await _authService.getToken();

    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $resolvedToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body["data"] as Map<String, dynamic>;
      }

      // ===============================
      // 🔄 AUTO REFRESH TOKEN
      // ===============================
      if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getLatestSensor();
      }

      throw Exception(
        "Failed to fetch sensor data: ${response.statusCode} - ${response.body}",
      );
    } catch (e) {
      throw Exception("SensorService Error: $e");
    }
  }

  // ===============================
  // 📈 GET SENSOR HISTORY (AUTO TOKEN)
  // ===============================
  String get _historyUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("BASE_URL is not set in .env");
    }
    return '$url/melon/history';
  }

  Future<List<Map<String, dynamic>>> getSensorHistory() async {
    final resolvedToken = await _authService.getToken();
    final uri = Uri.parse(_historyUrl);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $resolvedToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body["data"] as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getSensorHistory();
      }

      throw Exception(
        "Failed to fetch sensor history: ${response.statusCode} - ${response.body}",
      );
    } catch (e) {
      throw Exception("SensorService History Error: $e");
    }
  }
}
