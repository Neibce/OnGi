import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<bool> checkEmailExists(String email) async {
    final uri = Uri.parse('https://ongi-1049536928483.asia-northeast1.run.app/users/exists?email=$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'];
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }
}