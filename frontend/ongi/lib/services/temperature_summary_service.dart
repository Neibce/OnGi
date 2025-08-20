import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TemperatureSummaryService {
  // API URL
  static const String _baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app/';

  // 'Authorization' 헤더에 토큰을 포함하여 온도 정보를 가져오는 함수
  Future<Map<String, dynamic>> fetchTemperatureSummary(String familyId, String authToken) async {
    final String url = '$_baseUrl/temperature/summary?familyId=$familyId';

    // 요청 헤더 설정
    final headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      // 응답 상태가 200 OK일 경우
      if (response.statusCode == 200) {
        // 응답 데이터 파싱
        final Map<String, dynamic> data = json.decode(response.body);

        // 필요한 데이터 반환
        return {
          'familyTemperature': data['familyTemperature'],
          'totalFamilyDecreaseTemperature': data['totalFamilyDecreaseTemperature'],
          'totalFamilyIncreaseTemperature': data['totalFamilyIncreaseTemperature'],
          'totalMemberIncreaseTemperature': data['totalMemberIncreaseTemperature'],
          'memberIncreaseTemperatures': data['memberIncreaseTemperatures'],
        };
      } else {
        throw Exception('온도 요약 정보를 가져오는 데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      throw Exception('온도 요약 정보를 가져오는 데 오류가 발생했습니다: $e');
    }
  }
}

