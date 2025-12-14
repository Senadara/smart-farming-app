import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

enum SensorType { melon, ayam }

class SensorService {
  final AuthService _authService = AuthService();

  String _resolveUrl(SensorType type) {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception("BASE_URL is not set in .env");
    }

    switch (type) {
      case SensorType.melon:
        return '$baseUrl/melon/latest';
      case SensorType.ayam:
        return '$baseUrl/ayam/latest';
    }
  }

  // ===============================
  // 📡 GET SENSOR TERBARU (DINAMIS)
  // ===============================
  Future<Map<String, dynamic>> getLatestSensor(SensorType type) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(_resolveUrl(type));

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      }

      if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getLatestSensor(type);
      }

      throw Exception(
        'Failed to fetch ${type.name} sensor: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('SensorService (${type.name}) Error: $e');
    }
  }

  // ===============================
  // 📈 GET SENSOR HISTORY (DINAMIS)
  // ===============================
  String _resolveHistoryUrl(SensorType type) {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("BASE_URL is not set in .env");
    }

    switch (type) {
      case SensorType.melon:
        return '$url/melon/history';
      case SensorType.ayam:
        return '$url/ayam/history';
    }
  }

  Future<List<Map<String, dynamic>>> getSensorHistory(SensorType type) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(_resolveHistoryUrl(type));

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
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
        return await getSensorHistory(type);
      }

      throw Exception(
        'Failed to fetch ${type.name} history: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('SensorService (${type.name}) History Error: $e');
    }
  }
}
