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
        debugPrint('Data: $data');
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
        final list = data.map((json) => PenyakitAyam.fromJson(json)).toList();
        list.sort((a, b) {
          if (a.updatedAt == null && b.updatedAt == null) return 0;
          if (a.updatedAt == null) return 1;
          if (b.updatedAt == null) return -1;
          return b.updatedAt!.compareTo(a.updatedAt!);
        });
        return list;
      } else {
        throw Exception('Failed to load penyakit: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PenyakitAyam>> getPenyakitWithGejala() async {

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/with-gejala');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'];
        debugPrint('Data: $data');
        final list = data.map((json) => PenyakitAyam.fromJson(json)).toList();
        list.sort((a, b) {
          if (a.updatedAt == null && b.updatedAt == null) return 0;
          if (a.updatedAt == null) return 1;
          if (b.updatedAt == null) return -1;
          return b.updatedAt!.compareTo(a.updatedAt!);
        });
        return list;
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

  Future createPenyakitAyam(
      String namaPenyakit,
      List<Map<String, dynamic>> gejala) async {

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam');

    final payload = {
      'nama_penyakit': namaPenyakit,
      'gejala': gejala,
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

  Future<Map<String, dynamic>> updatePenyakitAyam(
      String id,
      String namaPenyakit,
      List<Map<String, dynamic>> gejala) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/$id');

    final payload = {
      'nama_penyakit': namaPenyakit,
      'gejala': gejala,
    };
    debugPrint('payload update penyakit: $payload');

    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(payload));
      debugPrint('response body update penyakit: ${response.body}');

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
          'message': decodedData['message'] ??
              'Gagal memperbarui penyakit: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deletePenyakitAyam(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/$id');

    try {
      final response = await http.delete(url, headers: headers);
      debugPrint('response body delete penyakit: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'status': true, 'message': 'Penyakit berhasil dihapus'};
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ??
              'Gagal menghapus penyakit: ${response.statusCode}',
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
    debugPrint('payload create gejala: $payload');

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
  Future<List<PenyakitAyam>> getPenyakitWithPenanganan() async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/with-penanganan');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'];
        debugPrint('data penyakit with penanganan: ${data.toString()}');
        final list = data.map((json) => PenyakitAyam.fromJson(json)).toList();
        list.sort((a, b) {
          if (a.updatedAt == null && b.updatedAt == null) return 0;
          if (a.updatedAt == null) return 1;
          if (b.updatedAt == null) return -1;
          return b.updatedAt!.compareTo(a.updatedAt!);
          
        });
        return list;
      } else {
        throw Exception('Failed to load penyakit with penanganan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePenangananPenyakitAyam(
      String id, String catatan, File? imageFile) async {
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
    final url = Uri.parse('$baseUrl/penyakit-ayam/penanganan/$id');

    final payload = <String, dynamic>{'catatan': catatan};
    if (imageUrl != null) payload['gambar'] = imageUrl;

    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(payload));
      debugPrint('response update penanganan: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': true, 'message': 'Penanganan berhasil diperbarui'};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'status': false,
          'message': decoded['message'] ??
              'Gagal memperbarui penanganan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deletePenangananPenyakitAyam(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/penanganan/$id');

    try {
      final response = await http.delete(url, headers: headers);
      debugPrint('response delete penanganan: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'status': true, 'message': 'Penanganan berhasil dihapus'};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'status': false,
          'message': decoded['message'] ??
              'Gagal menghapus penanganan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateGejalaAyam(
      String id, String namaGejala, File? imageFile) async {
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
    final url = Uri.parse('$baseUrl/gejala/$id');

    final payload = <String, dynamic>{
      'nama_gejala': namaGejala,
      if (imageUrl != null) 'gambar': imageUrl,
    };
    debugPrint('payload update gejala: $payload');

    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(payload));
      debugPrint('response body update gejala: ${response.body}');

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
          'message': decodedData['message'] ??
              'Gagal memperbarui gejala: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteGejalaAyam(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/penyakit-ayam/delete-gejala/$id');

    try {
      final response = await http.delete(url, headers: headers);
      debugPrint('response body delete gejala: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'status': true, 'message': 'Gejala berhasil dihapus'};
      } else {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return {
          'status': false,
          'message': decodedData['message'] ??
              'Gagal menghapus gejala: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// GET /penyakit-ayam/penanganan/by-gejala?gejala_ids=uuid1,uuid2,...
  /// Mengembalikan list penanganan yang terkait dengan gejala tertentu.
  /// Setiap item berisi data penanganan + informasi gejala terkait.
  Future<List<Map<String, dynamic>>> getPenangananByGejala(
      List<String> gejalaIds) async {
    if (gejalaIds.isEmpty) return [];

    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };

    final queryParam = gejalaIds.join(',');
    final url = Uri.parse(
        '$baseUrl/penyakit-ayam/penanganan/by-gejala?gejala_ids=$queryParam');

    debugPrint('Fetching penanganan by gejala: $url');

    try {
      final response = await http.get(url, headers: headers);
      debugPrint('response body penanganan by gejala: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> data = decodedData['data'] ?? [];
        return List<Map<String, dynamic>>.from(
            data.map((e) => Map<String, dynamic>.from(e)));
      } else {
        throw Exception(
            'Failed to load penanganan by gejala: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

