import 'package:ongi/models/temperature_contribution.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TemperatureService {
  final String baseUrl;
  TemperatureService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchFamilyTemperatureDaily(String familyCode) async {
    final url = Uri.parse('$baseUrl/temperature/daily?familyId=$familyCode');
    final token = await PrefsManager.getAccessToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dailyTemps = data['dailyTemperatures'] as List;
      return dailyTemps.map((e) => {
        'date': e['date'],
        'totalTemperature': (e['totalTemperature'] ?? 0).toDouble(),
      }).toList();
    } else {
      throw Exception('가족 온도 총합 정보 불러오기 실패 ${response.body}');
    }
  }

  Future<List<Contribution>> fetchFamilyTemperatureContributions(String familyCode) async {
    final url = Uri.parse('$baseUrl/temperature/contributions?familyId=$familyCode');
    final token = await PrefsManager.getAccessToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final contributionsList = data['contributions'] as List;
      return contributionsList.map((e) => Contribution.fromJson(e)).toList();
    } else {
      throw Exception('가족 온도 정보 불러오기 실패, ${response.body}');
    }
  }
}