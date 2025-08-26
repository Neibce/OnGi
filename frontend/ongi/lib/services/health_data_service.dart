import 'package:health/health.dart';

class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  final Health _health = Health();
  bool _isConfigured = false;

  /// Health 플러그인 초기화
  Future<bool> initialize() async {
    if (_isConfigured) return true;
    
    try {
      await _health.configure();
      _isConfigured = true;
      return true;
    } catch (e) {
      print('Health 초기화 실패: $e');
      return false;
    }
  }

  /// Health 권한 요청
  Future<bool> requestPermissions() async {
    if (!_isConfigured) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // 걸음 수 읽기 권한 요청
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      final bool requested = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      return requested;
    } catch (e) {
      print('Health 권한 요청 실패: $e');
      return false;
    }
  }

  /// 권한 확인
  Future<bool> hasPermissions() async {
    if (!_isConfigured) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      final types = [HealthDataType.STEPS];
      return await _health.hasPermissions(types) ?? false;
    } catch (e) {
      print('권한 확인 실패: $e');
      return false;
    }
  }

  /// 특정 날짜의 총 걸음 수 가져오기
  Future<int> getStepsForDate(DateTime date) async {
    if (!_isConfigured) {
      final initialized = await initialize();
      if (!initialized) return 0;
    }

    try {
      // 하루의 시작과 끝 시간 설정
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // 걸음 수 데이터 가져오기
      final int? steps = await _health.getTotalStepsInInterval(
        startOfDay,
        endOfDay,
      );

      return steps ?? 0;
    } catch (e) {
      print('걸음 수 조회 실패: $e');
      return 0;
    }
  }

  /// 오늘의 총 걸음 수 가져오기
  Future<int> getTodaySteps() async {
    return await getStepsForDate(DateTime.now());
  }

  /// 지정된 기간의 일별 걸음 수 가져오기
  Future<Map<DateTime, int>> getStepsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isConfigured) {
      final initialized = await initialize();
      if (!initialized) return {};
    }

    final Map<DateTime, int> stepsMap = {};

    try {
      // 날짜별로 걸음 수 조회
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || 
             currentDate.isAtSameMomentAs(endDate)) {
        final steps = await getStepsForDate(currentDate);
        stepsMap[DateTime(currentDate.year, currentDate.month, currentDate.day)] = steps;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return stepsMap;
    } catch (e) {
      print('기간별 걸음 수 조회 실패: $e');
      return {};
    }
  }

  /// Health 데이터 포인트로 상세 걸음 수 정보 가져오기
  Future<List<HealthDataPoint>> getDetailedStepsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isConfigured) {
      final initialized = await initialize();
      if (!initialized) return [];
    }

    // 현재는 상세 데이터를 지원하지 않음
    // 필요한 경우 나중에 구현
    try {
      // 상세 데이터는 현재 지원하지 않으므로 빈 리스트 반환
      return [];
    } catch (e) {
      print('상세 걸음 수 데이터 조회 실패: $e');
      return [];
    }
  }

  /// 실시간 걸음 수 모니터링 (주기적으로 호출)
  Future<int> getCurrentSteps() async {
    return await getTodaySteps();
  }

  /// Health 앱이 설치되어 있는지 확인 (iOS)
  Future<bool> isHealthAppAvailable() async {
    try {
      // iOS에서는 Health 앱이 기본적으로 설치되어 있음
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 권한과 초기화를 한번에 처리하는 헬퍼 메서드
  Future<bool> setupHealthData() async {
    try {
      // 1. 초기화
      final initialized = await initialize();
      if (!initialized) {
        print('Health 초기화 실패');
        return false;
      }

      // 2. 권한 확인
      final hasPermission = await hasPermissions();
      if (hasPermission) {
        print('Health 권한이 이미 있음');
        return true;
      }

      // 3. 권한 요청
      final requested = await requestPermissions();
      if (!requested) {
        print('Health 권한 요청 실패');
        return false;
      }

      print('Health 설정 완료');
      return true;
    } catch (e) {
      print('Health 설정 중 오류 발생: $e');
      return false;
    }
  }
}
