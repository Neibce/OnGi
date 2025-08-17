import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/prefs_manager.dart';
import 'fcm_service.dart';

class LoginService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      await PrefsManager.saveAccessToken(responseJson["accessToken"]);
      await PrefsManager.saveUserName(responseJson["userInfo"]["name"]);
      await PrefsManager.saveUuid(responseJson["userInfo"]["uuid"]);
      
      // isParent 정보도 저장
      if (responseJson["userInfo"]["isParent"] != null) {
        await PrefsManager.saveIsParent(responseJson["userInfo"]["isParent"]);
      }
      
      // 로그인 성공 후 FCM 토큰 업로드
      try {
        await FCMService.initializeAndUploadFCMToken();
      } catch (e) {
        print('FCM 토큰 업로드 중 오류 (로그인 후): $e');
        // FCM 오류가 발생해도 로그인은 성공으로 처리
      }
      
      return responseJson;
    } else {
      throw Exception('로그인 실패: ${response.statusCode} ${response.body}');
    }
  }
}
