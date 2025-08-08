import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ongi/utils/prefs_manager.dart';

Future<Map<String, String>> fetchFamilyInfo() async {
  final token = await PrefsManager.getAccessToken();
  if (token == null) throw Exception('로그인 필요');
  final url = Uri.parse('https://ongi-1049536928483.asia-northeast3.run.app/family');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return {
      'familycode': data['code'] ?? '',
      'familyname': data['name'] ?? '',
    };
  } else {
    throw Exception('가족 정보 불러오기 실패: ${response.body}');
  }
}