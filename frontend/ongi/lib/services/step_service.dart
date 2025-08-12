import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class StepService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> uploadSteps({required int steps}) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/steps'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'steps': steps}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('걸음 수 업로드에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('걸음 수 업로드 중 오류가 발생했습니다: $e');
    }
  }

  Future<Map<String, dynamic>?> getSteps({required String date}) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      String url = '$baseUrl/steps?date=$date';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          '걸음 수 조회에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('걸음 수 조회 중 오류가 발생했습니다: $e');
    }
  }

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
