import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/maumlog.dart';

class EmotionService {
  final String baseUrl;
  EmotionService({required this.baseUrl});

  Future<List<Emotion>> fetchEmotions() async {
    final response = await http.get(Uri.parse('$baseUrl/emotions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Emotion.fromJson(e)).toList();
    } else {
      throw Exception('감정 리스트를 불러오지 못했습니다');
    }
  }

  Future<void> uploadMaumLog({
    required String fileName,
    required String fileExtension,
    String? location,
    String? comment,
    required List<String> emotions, // Emotion enum code 리스트
  }) async {
    final url = Uri.parse('$baseUrl/maum-log');
    final body = jsonEncode({
      "fileName": fileName,
      "fileExtension": fileExtension,
      "location": location,
      "comment": comment,
      "emotions": emotions,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('업로드 실패: ${response.body}');
    }
  }

  Future<List<MaumLogRecord>> fetchMaumLogs() async {
    final response = await http.get(Uri.parse(' [baseUrl]/maum-log'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MaumLogRecord.fromJson(e)).toList();
    } else {
      throw Exception('마음기록 리스트를 불러오지 못했습니다');
    }
  }
}