import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  static const String baseUrl = 'https://visionaid.lolihunter.my.id/api'; // ganti sesuai backend kamu
  static const uuid = Uuid();

  // Generate ID baru untuk catatan
  static String generateNoteId() {
    return uuid.v4();
  }

  // Sinkronisasi (buat / update)
  static Future<bool> syncNote({
    required String apiKey,
    required String noteId,
    required String title,
    required String content,
    required DateTime updatedAt,
    bool isDraft = false, required String folder,
  }) async {
    final url = Uri.parse('$baseUrl/notes'); // ganti sesuai endpoint create/update

    final body = {
      "id": noteId,
      "title": title,
      "content": content,
      "updated_at": updatedAt.toIso8601String(),
      "is_draft": isDraft ? 1 : 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Sync failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error syncing note: $e");
      return false;
    }
  }

  // Ambil semua catatan user
  static Future<List<Map<String, dynamic>>> getNotes(String apiKey) async {
    final url = Uri.parse('$baseUrl/notes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Get notes failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }

  // Hapus catatan berdasarkan ID
  static Future<bool> deleteNote(String apiKey, String noteId) async {
    final url = Uri.parse('$baseUrl/notes/$noteId'); // sesuaikan dengan route

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete note failed: $e");
      return false;
    }
  }
}
