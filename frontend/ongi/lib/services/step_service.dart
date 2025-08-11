import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class StepService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';

  /// 걸음 수 조회
  static Future<Map<String, dynamic>> fetchSteps({String? date}) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      String url = '$baseUrl/steps';
      if (date != null) {
        url += '?date=$date';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('걸음 수를 불러오는 데에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('걸음 수를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 오늘의 총 걸음 수 조회
  static Future<int> getTodayTotalSteps() async {
    try {
      final data = await fetchSteps();
      return data['totalSteps'] ?? 0;
    } catch (e) {
      return 0; // 에러 발생 시 0 반환
    }
  }
}
