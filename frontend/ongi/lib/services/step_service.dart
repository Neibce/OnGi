import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ongi/utils/prefs_manager.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/update_frequency.dart';
import 'dart:async';

class StepService {
  static const String _baseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';

  // 실시간 관찰 관련 변수들
  static StreamSubscription? _observerSubscription;
  static bool _isObserving = false;

  // ==================== HealthKit 관련 메서드 ====================

  /// HealthKit 권한 요청
  Future<bool> requestPermissions() async {
    try {
      final readTypes = [QuantityType.stepCount.identifier];
      final writeTypes = [QuantityType.stepCount.identifier];
      
      return await HealthKitReporter.requestAuthorization(readTypes, writeTypes);
    } catch (e) {
      print('HealthKit 권한 요청 실패: $e');
      return false;
    }
  }

  /// 권한 확인
  Future<bool> hasPermissions() async {
    try {
      await _getStepsFromHealthKit(DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// HealthKit에서 걸음 수 가져오기 (내부 메서드)
  Future<int> _getStepsFromHealthKit(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final predicate = Predicate(startOfDay, endOfDay);
    final preferredUnits = await HealthKitReporter.preferredUnits([QuantityType.stepCount]);
    
    if (preferredUnits.isEmpty) return 0;
    
    final unit = preferredUnits.first.unit;
    final type = QuantityTypeFactory.from(QuantityType.stepCount.identifier);
    final quantities = await HealthKitReporter.quantityQuery(type, unit, predicate);

    return quantities.fold<int>(0, (sum, quantity) => sum + quantity.harmonized.value.toInt());
  }

  /// 오늘의 걸음 수 가져오기
  Future<int> getTodaySteps() async {
    try {
      return await _getStepsFromHealthKit(DateTime.now());
    } catch (e) {
      print('오늘 걸음 수 조회 실패: $e');
      return 0;
    }
  }

  /// 특정 날짜의 걸음 수 가져오기
  Future<int> getStepsForDate(DateTime date) async {
    try {
      return await _getStepsFromHealthKit(date);
    } catch (e) {
      print('특정 날짜 걸음 수 조회 실패: $e');
      return 0;
    }
  }

  // ==================== 실시간 관찰 관련 메서드 ====================

  /// 실시간 걸음 수 관찰 시작
  static Future<void> startObserving({required Function(int steps) onStepsChanged}) async {
    if (_isObserving) {
      print('이미 걸음 수 관찰 중입니다.');
      return;
    }

    try {
      final identifier = QuantityType.stepCount.identifier;
      
      _observerSubscription = HealthKitReporter.observerQuery(
        [identifier],
        null,
        onUpdate: (String updatedIdentifier) async {
          print('걸음 수 업데이트 감지: $updatedIdentifier');
          
          final stepService = StepService();
          final currentSteps = await stepService.getTodaySteps();
          onStepsChanged(currentSteps);
          
          // 서버에 자동 업로드
          try {
            await stepService.uploadSteps(steps: currentSteps);
            print('걸음 수 자동 업로드 성공: $currentSteps');
          } catch (e) {
            print('걸음 수 자동 업로드 실패: $e');
          }
        },
      );

      final isEnabled = await HealthKitReporter.enableBackgroundDelivery(
        identifier,
        UpdateFrequency.immediate,
      );

      if (isEnabled) {
        _isObserving = true;
        print('실시간 걸음 수 관찰 시작됨');
      } else {
        print('백그라운드 전달 활성화 실패');
      }
    } catch (e) {
      print('걸음 수 관찰 시작 실패: $e');
    }
  }

  /// 실시간 걸음 수 관찰 중지
  static Future<void> stopObserving() async {
    if (!_isObserving) return;

    try {
      await _observerSubscription?.cancel();
      _observerSubscription = null;

      await HealthKitReporter.disableBackgroundDelivery(QuantityType.stepCount.identifier);

      _isObserving = false;
      print('실시간 걸음 수 관찰 중지됨');
    } catch (e) {
      print('걸음 수 관찰 중지 실패: $e');
    }
  }

  /// 관찰 상태 확인
  static bool get isObserving => _isObserving;

  // ==================== 서버 API 관련 메서드 ====================

  /// 서버에 걸음 수 업로드
  Future<Map<String, dynamic>> uploadSteps({required int steps}) async {
    final accessToken = await PrefsManager.getAccessToken();
    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/steps'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'steps': steps}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return {'success': true, 'message': '걸음 수 업로드 성공'};
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('걸음 수 업로드에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('걸음 수 업로드 중 오류가 발생했습니다: $e');
    }
  }

  /// 서버에서 가족 걸음 수 조회
  Future<Map<String, dynamic>?> getStepsFromServer({String? date}) async {
    final accessToken = await PrefsManager.getAccessToken();
    if (accessToken == null) throw Exception('AccessToken이 없습니다.');

    try {
      String url = '$_baseUrl/steps';
      if (date != null) {
        url += '?date=$date';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('걸음수 조회 응답: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('걸음 수 조회에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('걸음 수 조회 중 오류가 발생했습니다: $e');
    }
  }

}