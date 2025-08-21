import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';

class PillService {
  static const String baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  static String _formatToHHmmss(String rawTime) {
    final String trimmed = rawTime.trim();

    // HH:mm:ss
    final hhmmss = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');
    if (hhmmss.hasMatch(trimmed)) {
      final parts = trimmed.split(':');
      final h = parts[0].padLeft(2, '0');
      return '$h:${parts[1]}:${parts[2]}';
    }

    // HH:mm
    final hhmm = RegExp(r'^\d{1,2}:\d{2}$');
    if (hhmm.hasMatch(trimmed)) {
      final parts = trimmed.split(':');
      final h = parts[0].padLeft(2, '0');
      return '$h:${parts[1]}:00';
    }

    // H 또는 HH
    final hOnly = RegExp(r'^\d{1,2}$');
    if (hOnly.hasMatch(trimmed)) {
      final h = trimmed.padLeft(2, '0');
      return '$h:00:00';
    }

    // 포맷을 알 수 없으면 원문 유지
    return trimmed;
  }

  /// 약 사진 업로드용 Presigned URL 요청
  static Future<Map<String, dynamic>> getPillPhotoPresignedUrl() async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pills/presigned-url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Presigned URL 요청에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Presigned URL 요청 중 오류가 발생했습니다: $e');
    }
  }

  /// S3에 약 사진 업로드
  static Future<void> uploadPillPhotoToS3({
    required String presignedUrl,
    required File imageFile,
    required String uploaderUuid,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final response = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': 'image/jpeg',
          'x-amz-meta-uploader': uploaderUuid,
        },
        body: bytes,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'S3 업로드에 실패했습니다. 상태 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('S3 업로드 중 오류가 발생했습니다: $e');
    }
  }

  /// 약 삭제
  static Future<void> deletePill(String pillId) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pills/$pillId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 삭제 성공
        return;
      } else {
        throw Exception(
          '약 삭제에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('약 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 약 추가
  static Future<Map<String, dynamic>> addPills({
    required String name,
    required int times,
    required String intakeDetail,
    required List<String> intakeTimes,
    required List<String> intakeDays,
    required String parentUuid,
    String? fileName, // 사진 파일명 추가
  }) async {
    final accessToken = await PrefsManager.getAccessToken();
    // final parentUuId = await PrefsManager.getUuid();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'times': times,
        'intakeDetail': intakeDetail,
        'intakeTimes': intakeTimes,
        'intakeDays': intakeDays,
        'parentUuid': parentUuid,
      };

      // 파일명이 있으면 추가
      if (fileName != null && fileName.isNotEmpty) {
        requestBody['fileName'] = fileName;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/pills'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{'status': 'ok'};
      } else {
        throw Exception(
          '약 추가에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('약 추가 중 오류가 발생했습니다: $e');
    }
  }

  /// 약 복용 기록 추가
  static Future<Map<String, dynamic>> addPillRecord({
    required String pillId,
    required String intakeTime,
    required DateTime intakeDate,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final String intakeDateStr =
          '${intakeDate.year.toString().padLeft(4, '0')}-${intakeDate.month.toString().padLeft(2, '0')}-${intakeDate.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('$baseUrl/pills/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'pillId': int.tryParse(pillId) ?? pillId,
          'intakeTime': _formatToHHmmss(intakeTime),
          'intakeDate': intakeDateStr,
        }),
      );

      if (response.statusCode == 200) {
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{'status': 'ok'};
      } else if (response.statusCode == 201) {
        if (response.body.isEmpty) {
          return <String, dynamic>{'status': 'created'};
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('약 복용 기록 추가에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('약 복용 기록 추가 중 오류가 발생했습니다: $e');
    }
  }

  /// 약 복용 기록 삭제
  static Future<Map<String, dynamic>> deletePillRecord({
    required String pillId,
    required String intakeTime,
    required DateTime intakeDate,
  }) async {
    final accessToken = await PrefsManager.getAccessToken();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final String intakeDateStr =
          '${intakeDate.year.toString().padLeft(4, '0')}-${intakeDate.month.toString().padLeft(2, '0')}-${intakeDate.day.toString().padLeft(2, '0')}';

      final response = await http.delete(
        Uri.parse('$baseUrl/pills/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'pillId': int.tryParse(pillId) ?? pillId,
          'intakeTime': _formatToHHmmss(intakeTime),
          'intakeDate': intakeDateStr,
        }),
      );

      if (response.statusCode == 200) {
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{'status': 'ok'};
      } else {
        throw Exception('약 복용 기록 삭제에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('약 복용 기록 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 오늘의 약 복용 예정 조회
  static Future<List<Map<String, dynamic>>> getTodayPillSchedule({String? parentUuid}) async {
    return getPillScheduleByDate(DateTime.now(), parentUuid: parentUuid);
  }

  /// 특정 날짜의 약 복용 예정 조회
  static Future<List<Map<String, dynamic>>> getPillScheduleByDate(
      DateTime date, {String? parentUuid}) async {
    final accessToken = await PrefsManager.getAccessToken();
    final defaultParentId = await PrefsManager.getUuid();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final String dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final targetParentId = parentUuid ?? defaultParentId;
      final response = await http.get(
        Uri.parse('$baseUrl/pills?parentUuid=$targetParentId&date=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
          '약 복용 일정을 불러오는 데에 실패했습니다. 상태 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  /// 특정 날짜의 약 복용 기록 조회
  static Future<List<Map<String, dynamic>>> getPillRecordsByDate(
      DateTime date, {String? parentUuid}) async {
    final accessToken = await PrefsManager.getAccessToken();
    final defaultParentId = await PrefsManager.getUuid();

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다. 로그인 먼저 하세요.');
    }

    try {
      final String dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final targetParentId = parentUuid ?? defaultParentId;
      final response = await http.get(
        Uri.parse('$baseUrl/pills/records?parentUuid=$targetParentId&date=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
          '약 복용 기록 조회에 실패했습니다. 상태 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }
}
