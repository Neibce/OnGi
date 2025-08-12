import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/maumlog.dart';

class MaumlogService {
  final String baseUrl;
  MaumlogService({this.baseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app'});

  Future<List<Emotion>> fetchEmotions() async {
    // final response = await http.get(Uri.parse('$baseUrl/emotions'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = json.decode(response.body);
    //   print(response.body);
    //   print(response.statusCode);
    //   return data.map((e) => Emotion.fromJson(e)).toList();
    // } else {
    //   throw Exception('감정 리스트를 불러오지 못했습니다, ${response.body}, ${response.statusCode}');
    // }
    // 백엔드 Emotion enum과 동일한 감정 리스트 ; 403 에러 해결 못함으로 일단 이렇게 처치해둠
    return [
      const Emotion(code: 'JOYFUL', description: '즐거움'),
      const Emotion(code: 'EXCITED', description: '설렘'),
      const Emotion(code: 'RELIEVED', description: '마음이 놓임'),
      const Emotion(code: 'SMIRK', description: '뿌듯함'),
      const Emotion(code: 'SADNESS', description: '서글픔'),
      const Emotion(code: 'STIFLED', description: '답답함'),
      const Emotion(code: 'WARMHEARTED', description: '마음이 따뜻'),
      const Emotion(code: 'EMPTY', description: '허전함'),
      const Emotion(code: 'REFRESHING', description: '시원섭섭함'),
      const Emotion(code: 'THRILL', description: '들뜸'),
      const Emotion(code: 'ANNOYED', description: '짜증남'),
      const Emotion(code: 'SORROWFUL', description: '서운함'),
      const Emotion(code: 'WORRIED', description: '걱정스러움'),
      const Emotion(code: 'MISSING', description: '그리움'),
      const Emotion(code: 'DEPRESSED', description: '울적함'),
      const Emotion(code: 'RELAXED', description: '여유로움'),
      const Emotion(code: 'CONFUSED', description: '마음이 복잡함'),
      const Emotion(code: 'CHEERFUL', description: '기운이 남'),
      const Emotion(code: 'COZY', description: '포근함'),
    ];
  }

  // Presigned URL 가져오기
  Future<Map<String, dynamic>> getPresignedUrls({
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/maum-log/presigned-url');
    print('🔑 Access Token: $accessToken');
    print('🌐 Request URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    print('📡 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Presigned URL 가져오기 실패: Status ${response.statusCode}, Body: ${response.body}');
    }
  }

  // S3에 파일 업로드
  Future<void> uploadFileToS3({
    required String presignedUrl,
    required File file,
    required String uploaderUuid,
  }) async {
    print('📁 업로드할 파일: ${file.path}');
    print('📤 S3 업로드 URL: $presignedUrl');
    
    final bytes = await file.readAsBytes();
    print('📊 파일 크기: ${bytes.length} bytes');
    
    final response = await http.put(
      Uri.parse(presignedUrl),
      body: bytes,
      headers: {
        'Content-Type': 'image/jpeg',
        'x-amz-meta-uploader': uploaderUuid,
      },
    );

    print('📡 S3 업로드 응답 상태: ${response.statusCode}');
    print('📄 S3 업로드 응답 본문: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('S3 파일 업로드 실패: Status ${response.statusCode}, Body: ${response.body}');
    }
    
    print('✅ S3 업로드 성공');
  }

  // 토큰 유효성 테스트 (사용자 정보 가져오기)
  Future<void> testTokenValidity({
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/me');
    print('🔍 토큰 유효성 테스트 URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );
    
    print('🔍 토큰 테스트 응답 상태: ${response.statusCode}');
    print('🔍 토큰 테스트 응답 본문: ${response.body}');
  }

  // 마음로그 조회 API 테스트
  Future<void> testMaumLogGet({
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/maum-log');
    print('📋 마음로그 조회 테스트 URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );
    
    print('📋 마음로그 조회 응답 상태.: ${response.statusCode}');
    print('📋 마음로그 조회 응답 본문: ${response.body}');
  }

  // 마음로그 메타데이터 업로드 (S3 업로드 후 호출)
  Future<void> uploadMaumLog({
    required String frontFileName,
    required String backFileName,
    String? location,
    String? comment,
    required List<String> emotions, // Emotion enum code
    required String accessToken,
  }) async {
    // 마음로그 업로드 실행
    
    final url = Uri.parse('$baseUrl/maum-log');
    final requestData = {
      "frontFileName": frontFileName,
      "backFileName": backFileName,
      "location": location,
      "comment": comment,
      "emotions": emotions,
    };
    final body = jsonEncode(requestData);
    
    print('🌐 마음로그 업로드 URL: $url');
    print('📋 요청 데이터: $requestData');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: body,
    ).timeout(Duration(seconds: 30));

    print('📡 마음로그 업로드 응답 상태: ${response.statusCode}');
    print('📄 마음로그 업로드 응답 본문: ${response.body}');
    print('📄 응답 헤더: ${response.headers}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ 마음로그 업로드 실패!');
      print('❌ Status: ${response.statusCode}');
      print('❌ Body: ${response.body}');
      throw Exception('마음로그 업로드 실패: Status ${response.statusCode}, Body: ${response.body}');
    }
    
    print('✅ 업로드 성공');
  }

  Future<List<MaumLogRecord>> fetchMaumLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/maum-log'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MaumLogRecord.fromJson(e)).toList();
    } else {
      throw Exception('마음기록 리스트를 불러오지 못했습니다');
    }
  }
}