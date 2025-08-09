import 'dart:convert';
import 'package:http/http.dart' as http;

class TemperatureService {
  final String baseUrl;
  TemperatureService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchFamilyTemperatureDaily(String familyCode, {String? token}) async {
    final url = Uri.parse('$baseUrl/temperature/daily?familyId=$familyCode');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['dailyTemperatures'] ?? []);
    } else {
      throw Exception('가족 온도 일별 데이터 불러오기 실패');
    }
  }

  Future<List<dynamic>> fetchFamilyTemperatureContributions(String familyCode, {String? token}) async {
    final url = Uri.parse('$baseUrl/temperature/contributions?familyId=$familyCode');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['contributions'] ?? [];

    } else {
      throw Exception('가족 온도 기여도 데이터 불러오기 실패');
    }
  }
}