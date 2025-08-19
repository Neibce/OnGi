import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/prefs_manager.dart';

class FCMService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  /// FCM 토큰을 서버에 업로드합니다.
  static Future<bool> uploadFCMToken(String fcmToken) async {
    try {
      final token = await PrefsManager.getAccessToken();
      if (token == null || token.isEmpty) {
        print('FCM 토큰 업로드 실패: 액세스 토큰이 없습니다');
        return false;
      }

      final url = Uri.parse('$baseUrl/users/fcm-token');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 201) {
        print('FCM 토큰 업로드 성공');
        return true;
      } else {
        print('FCM 토큰 업로드 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('FCM 토큰 업로드 중 오류 발생: $e');
      return false;
    }
  }

  static Future<String?> getFirebaseToken() async {
    String? fcmToken;
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } else {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
      }
    } else {
      fcmToken = await FirebaseMessaging.instance.getToken();
    }
    return fcmToken;
  }

  /// FCM 토큰을 가져와서 자동으로 서버에 업로드합니다.
  static Future<void> initializeAndUploadFCMToken() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // FCM 권한 상태 확인
      NotificationSettings settings = await messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('사용자가 알림 권한을 허용했습니다');


        final fcmToken = await getFirebaseToken();
        if (fcmToken != null) {
          print('FCM 토큰: $fcmToken');
          await uploadFCMToken(fcmToken);
        } else {
          print('FCM 토큰을 가져올 수 없습니다');
        }

        // FCM 토큰 갱신 리스너 설정
        messaging.onTokenRefresh.listen((newToken) async {
          print('FCM 토큰이 갱신되었습니다: $newToken');
          await uploadFCMToken(newToken);
        });
      } else {
        print('사용자가 알림 권한을 거부했습니다 (상태: ${settings.authorizationStatus})');
      }
    } catch (e) {
      print('FCM 초기화 중 오류 발생: $e');
    }
  }
}
