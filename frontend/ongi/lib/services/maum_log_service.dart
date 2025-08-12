import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/models/maum_log.dart';

class MaumLogService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  static Future<MaumLogResponse> getMaumLog(String date) async {
    final accessToken = await PrefsManager.getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maum-log?date=$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MaumLogResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('마음 기록을 불러오는 데에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('마음 기록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}
