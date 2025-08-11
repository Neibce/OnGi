import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/prefs_manager.dart';

class PainService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';
  
  // 통증 기록 추가
  static Future<Map<String, dynamic>?> addPainRecord({
    required String date,
    required String painArea,
    required String painLevel,
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
          'painArea': painArea,
          'painLevel': painLevel,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add pain record: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }
}

// 통증 부위 enum 매핑
enum PainArea {
  head('HEAD'),
  neck('NECK'),
  shoulder('SHOULDER'),
  chest('CHEST'),
  back('BACK'),
  arm('ARM'),
  hand('HAND'),
  abdomen('ABDOMEN'),
  waist('WAIST'),
  leg('LEG'),
  knee('KNEE'),
  foot('FOOT'),
  none('NONE');

  const PainArea(this.value);
  final String value;
}

// 통증 강도 enum
enum PainLevel {
  strong('STRONG'),
  midStrong('MID_STRONG'),
  midWeak('MID_WEAK'),
  weak('WEAK');

  const PainLevel(this.value);
  final String value;
}
