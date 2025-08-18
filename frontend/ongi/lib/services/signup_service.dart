import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required bool isParent,
    required int profileImageId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'isParent': isParent,
          'profileImageId': profileImageId,
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
