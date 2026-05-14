import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/service/image_service.dart';

class GejalaPenyakitAyam {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}';
  final AuthService _authService = AuthService();

  Future<List<GejalaModel>> getGejala() async {

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/gejala');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'];
        return data.map((json) => GejalaModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load gejala: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PenyakitAyam>> getPenyakit() async {

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'];
        return data.map((json) => PenyakitAyam.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load penyakit: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future diagnoseAyam(List<String> idGejala) async{

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/diagnosa');

    final payload = {
      'gejala': idGejala.map((id) => {'id': id}).toList()
    };
    
    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));

      debugPrint('response body diagnose: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': decodedData['data'],
        };
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ?? 'Failed to diagnose: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future createPenyakitAyam(String namaPenyakit, List<String> idGejala) async{

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam');

    final payload = {
      'nama_penyakit': namaPenyakit,
      'gejala_ids': idGejala.map((id) => id).toList()
    };
    
    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));
      debugPrint('response body create penyakit: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': decodedData['data'],
        };
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ?? 'Failed to add penyakit: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future createGejalaAyam(String namaGejala, File imageFile) async {
    final ImageService imageService = ImageService();
    final uploadResponse = await imageService.uploadImage(imageFile);

    if (uploadResponse['status'] == false) {
      throw Exception(uploadResponse['message']);
    }

    final imageUrl = uploadResponse['data'];

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/gejala');

    final payload = {
      'nama_gejala': namaGejala,
      'gambar': imageUrl,
    };

    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));
      debugPrint('response body create gejala: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': decodedData['data'],
        };
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ?? 'Gagal menambahkan gejala: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future createPenangananPenyakitAyam(String idPenyakit, String catatan, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      final ImageService imageService = ImageService();
      final uploadResponse = await imageService.uploadImage(imageFile);

      if (uploadResponse['status'] == false) {
        throw Exception(uploadResponse['message']);
      }
      imageUrl = uploadResponse['data'];
    }

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/penanganan');

    final payload = {
      'id_penyakit': idPenyakit,
      'catatan': catatan,
      'gambar': imageUrl,
    };

    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));
      debugPrint('response body create penanganan: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': decodedData['data'],
        };
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ?? 'Gagal menambahkan penanganan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }


  }
}

