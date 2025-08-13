import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class ExerciseService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> exerciseRecord({
    required String date,
    required List<List<int>> grid,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health/exercise/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'date': date, 'grid': grid}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('운동 기록 추가에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('운동 기록 추가 중 오류가 발생했습니다: $e');
    }
  }

  Future<Map<String, dynamic>?> getExerciseRecord({
    required String date,
    String? parentId,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();
    final defaultParentId = await PrefsManager.getUuid();

    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      String url = '$baseUrl/health/exercise/detail?date=$date';
      final targetParentId = parentId ?? defaultParentId;
      if (targetParentId != null) {
        url += '&parentId=$targetParentId';
      }

      print('운동 기록 조회 요청:');
      print('URL: $url');
      print('AccessToken: ${accessToken.substring(0, 20)}...');
      print('ParentId: $targetParentId');

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
          '운동 기록 조회에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('운동 기록 조회 중 오류가 발생했습니다: $e');
    }
  }
}
