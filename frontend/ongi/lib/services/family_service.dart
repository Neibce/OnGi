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
        var json = jsonDecode(response.body);
        PrefsManager.saveFamilyCodeAndName(json['code'], json['name']);
        return json;
      } else {
        throw Exception('Failed to get family info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return null;
    }
  }

  // 가족 멤버 조회
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final token = await PrefsManager.getAccessToken();

      if (token == null) {
        throw Exception('Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/family/members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json);
      } else {
        throw Exception('Failed to get family members: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('가족 멤버 조회 중 오류가 발생했습니다: $e');
    }
  }
}