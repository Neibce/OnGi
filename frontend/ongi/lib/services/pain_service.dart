import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/prefs_manager.dart';

class PainService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';
  
  // 통증 기록 추가
  static Future<Map<String, dynamic>?> addPainRecord({
    required String date,
    required List<String> painAreas,  // List로 변경
  }) async {
    try {
      final token = await PrefsManager.getAccessToken();
      
      if (token == null) {
        throw Exception('Access token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/health/pain/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': date,
          'painArea': painAreas,  // painLevel 제거, painArea는 List
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('통증 기록 API 오류: ${response.statusCode}, 응답: ${response.body}');
        throw Exception('Failed to add pain record: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('통증 기록 서비스 오류: $e');
      return null;
    }
  }
}

// 통증 부위 enum 매핑 (백엔드와 일치)
enum PainArea {
  head('HEAD'),
  neck('NECK'),
  leftShoulder('LEFT_SHOULDER'),
  rightShoulder('RIGHT_SHOULDER'),
  chest('CHEST'),
  back('BACK'),
  leftUpperArm('LEFT_UPPER_ARM'),
  rightUpperArm('RIGHT_UPPER_ARM'),
  leftForearm('LEFT_FOREARM'),
  rightForearm('RIGHT_FOREARM'),
  leftHand('LEFT_HAND'),
  rightHand('RIGHT_HAND'),
  abdomen('ABDOMEN'),
  waist('WAIST'),
  pelvis('PELVIS'),
  hip('HIP'),
  leftThigh('LEFT_THIGH'),
  rightThigh('RIGHT_THIGH'),
  leftCalf('LEFT_CALF'),
  rightCalf('RIGHT_CALF'),
  leftKnee('LEFT_KNEE'),
  rightKnee('RIGHT_KNEE'),
  leftFoot('LEFT_FOOT'),
  rightFoot('RIGHT_FOOT'),
  none('NONE');

  const PainArea(this.value);
  final String value;
}
