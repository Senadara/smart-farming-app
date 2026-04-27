import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class GejalaPenyakitAyam {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}';
  final AuthService _authService = AuthService();

  Future<List<GejalaModel>> getGejala() async {
    debugPrint("[GejalaService] Starting getGejala...");
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/gejala');
    debugPrint("[GejalaService] Requesting URL: $url");

    try {
      final response = await http.get(url, headers: headers);
      debugPrint("[GejalaService] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("[GejalaService] Response body: ${response.body}");
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'];
        debugPrint("data gejala: ${data.toString()}");
        return data.map((json) => GejalaModel.fromJson(json)).toList();
      } else {
        debugPrint(
            "[GejalaService] Error: Failed with status ${response.statusCode}. Body: ${response.body}");
        throw Exception('Failed to load gejala: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[GejalaService] Catch error: $e');
      rethrow;
    }
  }
}
