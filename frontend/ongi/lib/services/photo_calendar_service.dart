import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class PhotoCalendarService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> getPhotoCalendar({required String yearmonth}) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      String url = '$baseUrl/maum-log/calendar?yearMonth=$yearmonth';
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
        throw Exception(
          '마음기록 캘린더 조회에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('마음기록 캘린더 조회 중 오류가 발생했습니다: $e');
    }
  }
}
