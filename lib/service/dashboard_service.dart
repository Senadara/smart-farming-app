import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/service/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/dashboard';

  Future<Map<String, dynamic>> getDashboardPerkebunan() async {
    print('[DEBUG] getDashboardPerkebunan: Starting...');
    final resolvedToken = await _authService.getToken();
    print('[DEBUG] getDashboardPerkebunan: Token retrieved: ${resolvedToken != null ? "exists" : "null"}');
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/perkebunan');
    print('[DEBUG] getDashboardPerkebunan: Calling API: $url');
    
    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[DEBUG] getDashboardPerkebunan: API TIMEOUT after 15 seconds');
          throw Exception('Request timeout');
        },
      );
      print('[DEBUG] getDashboardPerkebunan: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print('[DEBUG] getDashboardPerkebunan: Success!');
        return body['data'];
      } else if (response.statusCode == 401) {
        print('[DEBUG] getDashboardPerkebunan: 401 Unauthorized, refreshing token...');
        final refreshSuccess = await _authService.refreshToken();
        if (refreshSuccess) {
          print('[DEBUG] getDashboardPerkebunan: Token refreshed, retrying...');
          return await getDashboardPerkebunan();
        } else {
          print('[DEBUG] getDashboardPerkebunan: Token refresh failed, throwing error');
          throw Exception('Session expired. Please login again.');
        }
      } else {
        print('[DEBUG] getDashboardPerkebunan: Failed with status ${response.statusCode}');
        throw Exception(
            'Failed to load dashboard perkebunan data ${response.statusCode}');
      }
    } catch (e) {
      print('[DEBUG] getDashboardPerkebunan: Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardPeternakan() async {
    print('[DEBUG] getDashboardPeternakan: Starting...');
    final resolvedToken = await _authService.getToken();
    print('[DEBUG] getDashboardPeternakan: Token retrieved: ${resolvedToken != null ? "exists" : "null"}');
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/peternakan');
    print('[DEBUG] getDashboardPeternakan: Calling API: $url');
    
    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[DEBUG] getDashboardPeternakan: API TIMEOUT after 15 seconds');
          throw Exception('Request timeout');
        },
      );
      print('[DEBUG] getDashboardPeternakan: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print('[DEBUG] getDashboardPeternakan: Success!');
        return body['data'];
      } else if (response.statusCode == 401) {
        print('[DEBUG] getDashboardPeternakan: 401 Unauthorized, refreshing token...');
        final refreshSuccess = await _authService.refreshToken();
        if (refreshSuccess) {
          print('[DEBUG] getDashboardPeternakan: Token refreshed, retrying...');
          return await getDashboardPeternakan();
        } else {
          print('[DEBUG] getDashboardPeternakan: Token refresh failed, throwing error');
          throw Exception('Session expired. Please login again.');
        }
      } else {
        print('[DEBUG] getDashboardPeternakan: Failed with status ${response.statusCode}');
        throw Exception('Failed to load dashboard peternakan data');
      }
    } catch (e) {
      print('[DEBUG] getDashboardPeternakan: Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> riwayatAktivitasAll(
      {int page = 1, int limit = 20}) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$baseUrl/riwayat-aktivitas?page=$page&limit=$limit');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      return body as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await riwayatAktivitasAll(page: page, limit: limit);
    } else {
      final body = json.decode(response.body);
      throw Exception(
          'Failed to load riwayat aktivitas data: ${body['message'] ?? response.reasonPhrase}');
    }
  }
}
