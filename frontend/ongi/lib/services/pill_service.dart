import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class PillService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';

  /// 약 복용 기록 추가
  static Future<Map<String, dynamic>> addPillRecord({
    required String pillName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pills/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'pillName': pillName,
          'dosage': dosage,
          'scheduledTime': scheduledTime.toIso8601String(),
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('약 복용 기록 추가에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('약 복용 기록 추가 중 오류가 발생했습니다: $e');
    }
  }

  /// 오늘의 약 복용 예정 조회
  static Future<List<Map<String, dynamic>>> getTodayPillSchedule() async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$baseUrl/pills?date=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('약 복용 일정을 불러오는 데에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      // 에러가 발생하면 빈 리스트 반환
      return [];
    }
  }
}
