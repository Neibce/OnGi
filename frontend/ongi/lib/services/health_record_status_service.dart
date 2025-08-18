import 'package:ongi/services/maum_log_service.dart';
import 'package:ongi/services/exercise_service.dart';
import 'package:ongi/services/health_service.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:intl/intl.dart';

class HealthRecordStatusService {
  /// 오늘의 건강기록이 있는지 확인하는 메서드
  /// 마음기록, 운동기록, 통증기록, 약 복용기록 중 하나라도 있으면 true 반환
  static Future<bool> hasTodayHealthRecord() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // 마음기록 확인
      final hasMaumLog = await _checkMaumLog(today);
      if (hasMaumLog) return true;
      
      // 운동기록 확인
      final hasExercise = await _checkExerciseRecord(today);
      if (hasExercise) return true;
      
      // 통증기록 확인
      final hasPain = await _checkPainRecord(today);
      if (hasPain) return true;
      
      // 약 복용기록 확인
      final hasPill = await _checkPillRecord(today);
      if (hasPill) return true;
      
      return false;
    } catch (e) {
      print('건강기록 상태 확인 중 오류: $e');
      return false; // 에러 발생 시 tooltip을 보여주도록 false 반환
    }
  }
  
  /// 마음기록 확인
  static Future<bool> _checkMaumLog(String date) async {
    try {
      final maumLogResponse = await MaumLogService.getMaumLog(date);
      return maumLogResponse.hasUploadedOwn;
    } catch (e) {
      print('마음기록 확인 실패: $e');
      return false;
    }
  }
  
  /// 운동기록 확인
  static Future<bool> _checkExerciseRecord(String date) async {
    try {
      final exerciseService = ExerciseService();
      final exerciseData = await exerciseService.getExerciseRecord(date: date);
      
      if (exerciseData != null && exerciseData['grid'] != null) {
        final List<List<int>> grid = (exerciseData['grid'] as List)
            .map((row) => (row as List).cast<int>())
            .toList();
        
        // grid에서 운동한 시간이 있는지 확인
        for (var row in grid) {
          for (var cell in row) {
            if (cell == 1) return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('운동기록 확인 실패: $e');
      return false;
    }
  }
  
  /// 통증기록 확인
  static Future<bool> _checkPainRecord(String date) async {
    try {
      final userInfo = await PrefsManager.getUserInfo();
      final userId = userInfo['uuid'];
      
      if (userId != null) {
        final painRecords = await HealthService.fetchPainRecords(userId);
        
        // 오늘 날짜의 통증기록이 있는지 확인
        return painRecords.any((record) => record['date'] == date);
      }
      return false;
    } catch (e) {
      print('통증기록 확인 실패: $e');
      return false;
    }
  }
  
  /// 약 복용기록 확인
  static Future<bool> _checkPillRecord(String date) async {
    try {
      final DateTime dateTime = DateTime.parse(date);
      final pillSchedule = await PillService.getPillScheduleByDate(dateTime);
      
      // 복용 완료된 약이 있는지 확인
      for (final pill in pillSchedule) {
        final Map<String, dynamic> status = Map<String, dynamic>.from(
          pill['dayIntakeStatus'] ?? {},
        );
        
        // 복용 상태가 하나라도 있으면 기록이 있다고 판단
        if (status.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('약 복용기록 확인 실패: $e');
      return false;
    }
  }
}
