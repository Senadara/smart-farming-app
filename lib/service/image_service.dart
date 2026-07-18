import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final String baseUrl = dotenv.env['CLOUDINARY_URL']?.trim() ?? '';
  final String apiKey = dotenv.env['CLOUDINARY_KEY']?.trim() ?? '';
  final String uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';

  Future<Map<String, dynamic>> uploadImage(File image) async {
    if (baseUrl.isEmpty) {
      return {
        'status': false,
        'message': 'CLOUDINARY_URL belum dikonfigurasi',
      };
    }

    if (uploadPreset.isEmpty || uploadPreset == 'nama_preset_kamu') {
      return {
        'status': false,
        'message':
            'CLOUDINARY_UPLOAD_PRESET belum valid. Gunakan preset unsigned smart_farming.',
      };
    }

    final url = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (apiKey.isNotEmpty) {
      request.fields['api_key'] = apiKey;
    }

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': data['secure_url'],
        };
      } else {
        final error = data['error'];
        final message = error is Map<String, dynamic>
            ? error['message']?.toString()
            : error?.toString();

        return {
          'status': false,
          'message': message ?? 'Cloudinary upload failed',
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
