import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class CodeService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> familyCreate ({
    required String name,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null)
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/family'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('회원가입에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }
}