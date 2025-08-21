import 'dart:convert';
import 'package:http/http.dart' as http;

class StepRankService {
  static const String baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app/';
  static const Duration timeout = Duration(seconds: 10);

  static Future<List<FamilyStepRank>> fetchFamilyStepRanks(String accessToken) async {
    try {
      final url = Uri.parse('$baseUrl/steps/rank');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // API 응답이 배열인지 객체인지 확인
        List<dynamic> data;
        if (responseBody is List) {
          data = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          data = responseBody['data'] ?? responseBody['familyRanks'] ?? [];
        } else {
          throw Exception('예상하지 못한 응답 형태입니다.');
        }

        return data.map((e) => FamilyStepRank.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else if (response.statusCode == 403) {
        throw Exception('접근 권한이 없습니다.');
      } else if (response.statusCode >= 500) {
        throw Exception('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      } else {
        throw Exception('걸음 수 랭킹 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('네트워크 연결이 불안정합니다. 다시 시도해주세요.');
      }
      rethrow;
    }
  }
}

class FamilyStepRank {
  final String familyName;
  final int averageSteps;
  final bool isOurFamily;

  FamilyStepRank({
    required this.familyName,
    required this.averageSteps,
    required this.isOurFamily,
  });

  factory FamilyStepRank.fromJson(Map<String, dynamic> json) {
    return FamilyStepRank(
      familyName: json['familyName']?.toString() ?? '',
      averageSteps: _parseSteps(json['averageSteps']),
      isOurFamily: json['isOurFamily'] == true,
    );
  }

  static int _parseSteps(dynamic steps) {
    if (steps is int) return steps;
    if (steps is String) return int.tryParse(steps) ?? 0;
    if (steps is double) return steps.round();
    return 0;
  }

  @override
  String toString() {
    return 'FamilyStepRank(familyName: $familyName, averageSteps: $averageSteps, isOurFamily: $isOurFamily)';
  }
}