import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/screens/health/exercise_record_screen.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/health/family_step_tracker_screen.dart';
import 'package:ongi/screens/health/pill_history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/health/health_status_input_screen.dart';
import 'package:ongi/services/exercise_service.dart';
import 'package:ongi/services/step_service.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/services/health_service.dart';
import 'package:ongi/services/family_service.dart';
import 'package:intl/intl.dart';
import 'package:ongi/screens/health/cross_family_ranking_screen.dart';

class HealthHomeScreen extends StatefulWidget {
  const HealthHomeScreen({super.key});

  @override
  State<HealthHomeScreen> createState() => _HealthHomeScreenState();
}

// 전역 키를 사용해서 외부에서 새로고침 메서드에 접근할 수 있도록 함
final GlobalKey<_HealthHomeScreenState> healthHomeScreenKey = GlobalKey<_HealthHomeScreenState>();

class _HealthHomeScreenState extends State<HealthHomeScreen> {
  String username = '사용자';
  String _currentView = 'home'; // 'home', 'pain', 'pills', 'exercise', 'steps'
  int _todayExerciseHours = 0;
  int _todayExerciseMinutes = 0;
  bool _isLoadingExercise = true;
  int _todaySteps = 0;
  int _todayPillCount = 0;

  // 통증 기록 관련 상태
  List<Map<String, dynamic>> _todayPainRecords = [];
  bool _isLoadingPain = true;

  // 자녀 사용자 관련 상태
  bool _isChild = false;
  List<Map<String, dynamic>> _parentMembers = [];
  String? _selectedParentId;
  bool _isLoadingParents = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final isParent = await PrefsManager.getIsParent();
      _isChild = !isParent;

      await _loadUserName();

      if (_isChild) {
        await _loadParentMembers();
      } else {
        // 부모인 경우 바로 데이터 로드
        await _loadAllData();
      }
    } catch (e) {
      print('사용자 타입 확인 실패: $e');
      await _loadAllData(); // 오류 시 기본 동작
    }
  }

  Future<void> _loadUserName() async {
    String? savedUsername = await PrefsManager.getUserName();
    if (savedUsername != null) {
      setState(() {
        username = savedUsername;
      });
    }
  }

  Future<void> _loadParentMembers() async {
    setState(() {
      _isLoadingParents = true;
    });

    try {
      final members = await FamilyService.getFamilyMembers();
      final parents = members
          .where((member) => member['isParent'] == true)
          .toList();

      setState(() {
        _parentMembers = parents;
        _isLoadingParents = false;

        // 첫 번째 부모를 기본 선택
        if (parents.isNotEmpty) {
          _selectedParentId = parents.first['uuid'];
        }
      });

      // 선택된 부모의 데이터 로드
      if (_selectedParentId != null) {
        await _loadAllData();
      }
    } catch (e) {
      print('부모 멤버 로드 실패: $e');
      setState(() {
        _isLoadingParents = false;
      });
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadTodayExerciseTime(),
      _loadStep(),
      _loadPillCount(),
      _loadTodayPainRecords(),
    ]);
  }

  // 외부에서 호출 가능한 새로고침 메서드
  Future<void> refreshHealthData() async {
    try {
      if (_isChild) {
        // 자녀인 경우 부모 목록도 새로고침
        await _loadParentMembers();
      } else {
        // 부모인 경우 바로 데이터 새로고침
        await _loadAllData();
      }
    } catch (e) {
      // 새로고침 실패 시 조용히 처리
      print('건강 데이터 새로고침 실패: $e');
    }
  }

  void _onParentSelected(String parentId) {
    setState(() {
      _selectedParentId = parentId;
    });
    _loadAllData(); // 선택된 부모의 데이터 다시 로드
  }

  String _formatNameForDisplay(String name) {
    if (name.length == 2) {
      // 2글자: 그대로 표출
      return name;
    } else if (name.length == 3) {
      // 3글자: 앞 한글자 자르고 표출
      return name.substring(1);
    } else if (name.length == 4) {
      // 4글자: 뒷 3글자만 표출
      return name.substring(1);
    } else if (name.length > 4) {
      // 4글자 이상: 앞 3글자만 표출
      return name.substring(0, 3);
    } else {
      // 1글자 또는 예외 상황: 그대로 표출
      return name;
    }
  }

  Future<void> _loadTodayExerciseTime() async {
    try {
      final now = DateTime.now();
      final dateKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final exerciseService = ExerciseService();

      // 자녀인 경우 선택된 부모의 데이터 조회
      final targetUserId = _isChild ? _selectedParentId : null;
      final serverData = await exerciseService.getExerciseRecord(
        date: dateKey,
        parentId: targetUserId,
      );

      if (serverData != null && serverData['grid'] != null) {
        final List<List<int>> serverGrid = (serverData['grid'] as List)
            .map((row) => (row as List).cast<int>())
            .toList();

        int totalCells = 0;
        for (var row in serverGrid) {
          for (var cell in row) {
            if (cell == 1) totalCells++;
          }
        }

        final totalMinutes = totalCells * 10;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;

        setState(() {
          _todayExerciseHours = hours;
          _todayExerciseMinutes = minutes;
          _isLoadingExercise = false;
        });
      } else {
        setState(() {
          _todayExerciseHours = 0;
          _todayExerciseMinutes = 0;
          _isLoadingExercise = false;
        });
      }
    } catch (e) {
      print('오늘 운동 시간 조회 실패: $e');
      setState(() {
        _todayExerciseHours = 0;
        _todayExerciseMinutes = 0;
        _isLoadingExercise = false;
      });
    }
  }

  Future<void> _loadStep() async {
    try {
      final stepService = StepService();

      // 오늘 데이터를 가져올 때는 date 파라미터를 생략
      final serverData = await stepService.getStepsFromServer();

      int todaySteps = 0;
      if (serverData != null) {
        final userInfo = await PrefsManager.getUserInfo();
        final currentUserId = userInfo['uuid'];

        if (serverData['memberSteps'] != null && currentUserId != null) {
          final List<dynamic> memberSteps = serverData['memberSteps'];
          final currentUserStep = memberSteps.firstWhere(
            (member) => member['userId'] == currentUserId,
            orElse: () => null,
          );

          if (currentUserStep != null) {
            todaySteps = currentUserStep['steps'] ?? 0;
          }
        } else {
          final dynamic stepsField =
              serverData['steps'] ??
              serverData['totalSteps'] ??
              serverData['total'];
          if (stepsField is int) {
            todaySteps = stepsField;
          } else if (stepsField != null) {
            todaySteps = int.tryParse(stepsField.toString()) ?? 0;
          }
        }
      }

      if (mounted) {
        setState(() {
          _todaySteps = todaySteps;
        });
      }
    } catch (e) {
      print('오늘 걸음 수 조회 실패: $e');
      if (mounted) {
        setState(() {
          _todaySteps = 0;
        });
      }
    }
  }

  Future<void> _loadPillCount() async {
    try {
      // 자녀인 경우 선택된 부모의 약 정보 조회
      final targetUserId = _isChild ? _selectedParentId : null;
      final pillSchedule = await PillService.getTodayPillSchedule(
        parentUuid: targetUserId,
      );

      // 총 복용해야 할 횟수와 이미 복용한 횟수 계산
      int totalIntakes = 0;
      int takenIntakes = 0;

      for (var pill in pillSchedule) {
        final List<dynamic> intakeTimes = pill['intakeTimes'] ?? [];
        final Map<String, dynamic> dayIntakeStatus =
            pill['dayIntakeStatus'] ?? {};

        totalIntakes += intakeTimes.length;

        // dayIntakeStatus에서 실제 복용한 시간들을 확인
        for (var intakeTime in intakeTimes) {
          final timeKey = intakeTime.toString().substring(
            0,
            5,
          ); // "08:00:00" -> "08:00"
          if (dayIntakeStatus.containsKey(timeKey)) {
            takenIntakes++;
          }
        }
      }

      // 남은 복용 횟수
      int remainingIntakes = totalIntakes - takenIntakes;
      if (remainingIntakes < 0) remainingIntakes = 0;

      setState(() {
        _todayPillCount = remainingIntakes;
      });
    } catch (e) {
      print('오늘 약 개수 조회 실패: $e');
      setState(() {
        _todayPillCount = 0;
      });
    }
  }

  Future<void> _loadTodayPainRecords() async {
    setState(() {
      _isLoadingPain = true;
    });

    try {
      // 자녀인 경우 선택된 부모의 통증 기록 조회, 부모인 경우 본인 기록 조회
      String? targetUserId;
      if (_isChild) {
        targetUserId = _selectedParentId;
      } else {
        final userInfo = await PrefsManager.getUserInfo();
        targetUserId = userInfo['uuid'];
      }

      if (targetUserId != null) {
        final painRecords = await HealthService.fetchPainRecords(targetUserId);
        final today = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(today);

        final todayPainRecords = painRecords
            .where((record) => record['date'] == todayStr)
            .toList();

        setState(() {
          _todayPainRecords = todayPainRecords;
          _isLoadingPain = false;
        });
      }
    } catch (e) {
      print('통증 기록 조회 실패: $e');
      setState(() {
        _todayPainRecords = [];
        _isLoadingPain = false;
      });
    }
  }

  String _convertPainAreaToKorean(String painArea) {
    final painAreaMap = {
      'HEAD': '머리',
      'NECK': '목',
      'LEFT_SHOULDER': '왼쪽 어깨',
      'RIGHT_SHOULDER': '오른쪽 어깨',
      'CHEST': '가슴',
      'BACK': '등',
      'LEFT_UPPER_ARM': '왼쪽 윗팔',
      'RIGHT_UPPER_ARM': '오른쪽 윗팔',
      'LEFT_FOREARM': '왼쪽 아랫팔',
      'RIGHT_FOREARM': '오른쪽 아랫팔',
      'LEFT_HAND': '왼쪽 손',
      'RIGHT_HAND': '오른쪽 손',
      'ABDOMEN': '복부',
      'WAIST': '허리',
      'PELVIS': '골반',
      'HIP': '엉덩이',
      'LEFT_THIGH': '왼쪽 허벅지',
      'RIGHT_THIGH': '오른쪽 허벅지',
      'LEFT_CALF': '왼쪽 종아리',
      'RIGHT_CALF': '오른쪽 종아리',
      'LEFT_KNEE': '왼쪽 무릎',
      'RIGHT_KNEE': '오른쪽 무릎',
      'LEFT_FOOT': '왼쪽 발',
      'RIGHT_FOOT': '오른쪽 발',
      'NONE': '없음',
    };
    return painAreaMap[painArea] ?? painArea;
  }

  Widget _buildPainText() {
    if (_isLoadingPain) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통증 기록을',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          Text(
            '불러오는 중...',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_todayPainRecords.isNotEmpty) {
      // 디버깅: 실제 painArea 값들 출력
      for (var record in _todayPainRecords) {
        print('home_screen 디버깅 - painArea 원본: ${record['painArea']}');
        print(
          'home_screen 디버깅 - painArea 타입: ${record['painArea'].runtimeType}',
        );
        print(
          'home_screen 디버깅 - 한글 변환: ${_convertPainAreaToKorean(record['painArea'].toString())}',
        );
      }

      final koreanAreas = _todayPainRecords
          .expand((record) {
            final painArea = record['painArea'];
            if (painArea is List) {
              // painArea가 List인 경우 각 항목을 변환
              return painArea.map(
                (area) => _convertPainAreaToKorean(area.toString()),
              );
            } else {
              // painArea가 단일 값인 경우
              return [_convertPainAreaToKorean(painArea.toString())];
            }
          })
          .toSet()
          .join(', ');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            koreanAreas,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const Text(
            '불편해요!',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    // 기본 제목 (통증 기록이 없을 때)
    if (_isChild) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통증 기록이 아직',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '입력되지 \n않았어요!',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      );
    } else {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어느 곳이',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '불편하세요?',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
  }

  void _changeView(String viewName) {
    setState(() {
      _currentView = viewName;
    });
  }

  void _refreshExerciseTime() {
    _loadTodayExerciseTime();
  }

  Widget _buildExerciseTimeText() {
    if (_todayExerciseHours == 0 && _todayExerciseMinutes == 0) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '아직 운동 기록이',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          Text(
            '없어요!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    String timeText = '';
    if (_todayExerciseHours > 0 && _todayExerciseMinutes > 0) {
      timeText = '오늘은 ${_todayExerciseHours}시간 ${_todayExerciseMinutes}분';
    } else if (_todayExerciseHours > 0) {
      timeText = '오늘은 ${_todayExerciseHours}시간';
    } else {
      timeText = '오늘은 ${_todayExerciseMinutes}분';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeText,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        const Text(
          '운동하셨네요!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameSection() {
    if (_isChild && !_isLoadingParents) {
      // 자녀인 경우 드롭다운 표시
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedParentId,
                  icon: const SizedBox.shrink(),
                  dropdownColor: Colors.white,
                  isDense: false,
                  itemHeight: 80, // 높이 증가로 폰트 클리핑 방지
                  borderRadius: BorderRadius.circular(20),
                  isExpanded: false, // 내용에 맞는 너비
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ongiOrange,
                    height: 1.1, // 줄 높이 조정으로 클리핑 방지
                  ),
                  items: _parentMembers.map((parent) {
                    return DropdownMenuItem<String>(
                      value: parent['uuid'],
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatNameForDisplay(parent['name']),
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ongiOrange,
                            height: 1.1, // 줄 높이 조정
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _onParentSelected(newValue);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // 간격 추가
          const Text(
            '님의',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w200,
              height: 1.2,
              color: AppColors.ongiOrange,
            ),
          ),
        ],
      );
    } else if (_isLoadingParents) {
      // 부모 목록 로딩 중
      return const Text(
        '로딩 중...',
        style: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w200,
          height: 1.2,
          color: AppColors.ongiOrange,
        ),
      );
    } else {
      // 부모인 경우 기존과 동일
      return Text(
        '$username님의',
        style: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w200,
          height: 1.2,
          color: AppColors.ongiOrange,
        ),
      );
    }
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'pain':
        return _buildPainInputView();
      case 'pills':
        return _buildPillHistoryView();
      case 'exercise':
        return _buildExerciseView();
      case 'steps':
        return _buildStepTrackerView();
      case 'familyStepTracker':
        return Stack(
          children: [const FamilyStepTrackerScreen(), _buildBackButton()],
        );
      case 'crossFamilyRanking':
        return Stack(
          children: [const CrossFamilyRankingScreen(), _buildBackButton()],
        );
      default:
        return _buildHomeView();
    }
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        child: IconButton(
          icon: SvgPicture.asset('assets/images/back_icon_white.svg'),
          onPressed: _goBackToHome,
        ),
      ),
    );
  }

  Widget _buildPainInputView() {
    return Stack(
      children: [
        HealthStatusInputScreen(
          selectedParentId: _selectedParentId,
          isChild: _isChild,
        ),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildPillHistoryView() {
    return Stack(
      children: [
        PillHistoryScreen(
          selectedParentId: _selectedParentId,
          isChild: _isChild,
        ),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildExerciseView() {
    return Stack(
      children: [
        ExerciseRecordScreen(
          selectedParentId: _selectedParentId,
          isChild: _isChild,
        ),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildStepTrackerView() {
    return Stack(
      children: [const FamilyStepTrackerScreen(), _buildBackButton()],
    );
  }

  Widget _buildNoParentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 또는 이미지 (선택사항)
            Icon(
              Icons.family_restroom,
              size: 80,
              color: AppColors.ongiOrange.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 40),

            // 메인 메시지
            const Text(
              '아직 등록된\n부모 사용자가 없어요.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.ongiOrange,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 서브 메시지
            const Text(
              '부모님을 초대해볼까요?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.ongiOrange,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 새로고침 버튼 (선택사항)
            OutlinedButton(
              onPressed: () {
                _loadParentMembers();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ongiOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: AppColors.ongiOrange, width: 2),
              ),
              child: const Text(
                '새로고침',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeView() {
    // 자녀인데 부모가 없는 경우 안내 화면 표시
    if (_isChild && _parentMembers.isEmpty && !_isLoadingParents) {
      return _buildNoParentView();
    }

    return RefreshIndicator(
      onRefresh: refreshHealthData,
      color: AppColors.ongiOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(height: 130),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserNameSection(),
                const Text(
                  '건강 기록',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.ongiOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _changeView('pain'),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildPainText(),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 120,
                          child: SvgPicture.asset(
                            'assets/images/ruler_icon.svg',
                            width: 32,
                          ),
                        ),
                        Positioned(
                          left: 160,
                          top: 40,
                          child: Image.asset(
                            'assets/images/sitting_mom_icon.png',
                            width: 200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      foregroundColor: AppColors.ongiOrange,
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _changeView('pills'),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 5,
                          bottom: 10,
                          child: Image.asset(
                            'assets/images/pill_history_title_logo.png',
                            width: 150,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text.rich(
                            TextSpan(
                              children: _todayPillCount == 0
                                  ? [
                                      const TextSpan(
                                        text: '오늘의 약을\n',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '모두 섭취하셨어요!',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: AppColors.ongiOrange,
                                        ),
                                      ),
                                    ]
                                  : [
                                      const TextSpan(
                                        text: '오늘 약을 ',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$_todayPillCount번',
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: AppColors.ongiOrange,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _isChild
                                            ? '\n섭취하지 않으셨어요!'
                                            : '\n더 섭취하셔야 해요!',
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 130,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.fromLTRB(20, 14, 10, 0),
                          backgroundColor: AppColors.ongiOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _changeView('exercise'),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _isLoadingExercise
                              ? const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '운동 시간을',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '불러오는 중...',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : _buildExerciseTimeText(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: -20,
                      child: IgnorePointer(
                        child: Container(
                          height: 150,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: Image.asset(
                            'assets/images/parent_exercise_icon.png',
                            width: 170,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      foregroundColor: AppColors.ongiOrange,
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _changeView('familyStepTracker'),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 15,
                          bottom: 10,
                          child: Image.asset(
                            'assets/images/step_tracker_title_logo.png',
                            width: 100,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '오늘은 ',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${_todaySteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},').replaceAll(RegExp(r',$'), '')}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: AppColors.ongiOrange,
                                  ),
                                ),
                                const TextSpan(
                                  text: '걸음\n걸으셨어요!',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 8,
                          child: GestureDetector(
                            onTap: () => _changeView('crossFamilyRanking'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/step_ranking_icon.svg',
                                    height: 18,
                                    width: 18,
                                    color: AppColors.ongiGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 0.6,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '다른 가족들은 몇 걸음 걸었을까요?',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _goBackToHome() {
    setState(() {
      _currentView = 'home';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(child: _buildCurrentView()),
    );
  }
}

