import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class HealthService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';

  /// 최근 7일간 부모의 통증 기록 조회
  static Future<List<Map<String, dynamic>>> fetchPainRecords(String parentId) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health/pain/view?parentId=$parentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('통증 기록을 불러오는 데에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('통증 기록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}
