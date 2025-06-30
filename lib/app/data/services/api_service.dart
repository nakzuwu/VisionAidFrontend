import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vision_aid_app/app/data/model/note_model.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseUrl = 'https://visionaid.lolihunter.my.id/';

  static Future<Note?> fetchNote(String noteId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/notes/$noteId'));
    if (response.statusCode == 200) {
      return Note.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<bool> syncNote(Note note) async {
    final endpoint =
        note.id != null
            ? '$baseUrl/api/notes/${note.id}'
            : '$baseUrl/api/notes';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
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
      Get.snackbar('Gagal', 'Status ${response.statusCode}');
      return null;
    }
  }
}
