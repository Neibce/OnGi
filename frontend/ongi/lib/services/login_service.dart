import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/token_storage.dart';

class LoginService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast1.run.app';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      await TokenStorage.saveAccessToken(responseJson["accessToken"]);
      return responseJson;
    } else {
      throw Exception('로그인 실패: ${response.statusCode} ${response.body}');
    }
  }
}
