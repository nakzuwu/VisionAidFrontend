import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vision_aid_app/app/data/model/note_model.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseUrl = 'https://visionaid.lolihunter.my.id';

  static Future<List<Note>> fetchAllNotes() async {
    final jwt = GetStorage().read('token');
    if (jwt == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/notes/all'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    }
    return [];
  }

  static Future<bool> syncNote(Note note) async {
    final jwt = GetStorage().read('token');
    if (jwt == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/api/notes/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(note.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteNote(String noteId) async {
    final jwt = GetStorage().read('token');
    if (jwt == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/api/notes/$noteId/delete'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    return response.statusCode == 200;
  }

  static Future<String?> uploadImage(String noteId, String imagePath) async {
    final file = File(imagePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/notes/$noteId/images'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: imagePath.split('/').last,
      ),
    );

    final response = await request.send();
    if (response.statusCode == 201) {
      final responseData = await response.stream.bytesToString();
      final imageUrl = json.decode(responseData)['url'];
      return imageUrl;
    }
    return null;
  }

  Future<Map<String, dynamic>?> summarizeText(String text) async {
    const url = '$baseUrl/api/summarize';
    final apiKey = GetStorage().read('api_key');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey ?? '',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadOCRImage(
    File imageFile,
    String apiKey,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/ocr');
      final request =
          http.MultipartRequest('POST', url)
            ..headers['X-API-KEY'] = apiKey
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        return json.decode(body);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadAudio(File file) async {
    final token = GetStorage().read('token');
    if (token == null) {
      Get.snackbar('Error', 'Token belum tersedia, silakan login ulang.');
      return null;
    }

    try {
      Get.snackbar('Sedang Diproses', 'Audio sedang dikirim ke server...');
      final uri = Uri.parse('$baseUrl/api/transcribe');

      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        return resStr;
      } else {
        Get.snackbar('Gagal', 'Status kode: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
      return null;
    }
  }
}
