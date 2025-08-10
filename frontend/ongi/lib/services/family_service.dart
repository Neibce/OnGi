import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/prefs_manager.dart';

class FamilyService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';

  // 가족 정보 조회
  static Future<Map<String, dynamic>?> getFamilyInfo() async {
    try {
      final token = await PrefsManager.getAccessToken();
      
      if (token == null) {
        throw Exception('Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/family'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );



      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get family info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return null;
    }
  }
}
