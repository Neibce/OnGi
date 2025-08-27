import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/services/step_service.dart';
import 'package:ongi/services/family_service.dart';
import 'package:ongi/services/health_data_service.dart';
import 'package:ongi/utils/prefs_manager.dart';

class FamilyStepTrackerScreen extends StatefulWidget {
  const FamilyStepTrackerScreen({super.key});

  @override
  State<FamilyStepTrackerScreen> createState() =>
      _FamilyStepTrackerScreenState();
}

class _FamilyStepTrackerScreenState extends State<FamilyStepTrackerScreen> {
  Map<int, int> selectedDosages = {};
  late final PageController _dateCarouselController;
  DateTime selectedDate = DateTime.now();
  final StepService _stepService = StepService();
  final HealthDataService _healthDataService = HealthDataService();
  bool _isLoading = false;
  int _totalSteps = 0;
  int _deviceSteps = 0; // 디바이스에서 가져온 걸음 수
  String? _errorMessage;
  List<_MemberStep> _memberSteps = [];
  bool _hasHealthPermission = false;
  Timer? _stepUpdateTimer;

  @override
  void initState() {
    super.initState();
    _dateCarouselController = PageController(initialPage: 5000);
    _initializeHealthData();
  }

  /// Health 데이터 권한 상태 확인 (권한 요청은 앱 시작 시에만)
  Future<void> _initializeHealthData() async {
    try {
      // Health 초기화 (권한 요청 없이)
      await _healthDataService.initialize();
      
      // 권한 확인을 위해 실제 데이터 접근 시도
      try {
        final todaySteps = await _healthDataService.getTodaySteps();
        // 데이터를 성공적으로 가져왔으면 권한이 있는 것
        setState(() {
          _hasHealthPermission = true;
          _deviceSteps = todaySteps;
        });
        print('Health 권한 확인됨 - 실제 걸음수: $todaySteps');
        _startStepUpdateTimer();
      } catch (e) {
        // 데이터 접근 실패시 권한 없음
        print('Health 데이터 접근 실패: $e');
        final hasPermission = await _healthDataService.hasPermissions();
        setState(() {
          _hasHealthPermission = hasPermission;
        });
        print('Health 권한 상태: $hasPermission');
      }
    } catch (e) {
      print('Health 권한 확인 오류: $e');
      setState(() {
        _hasHealthPermission = false;
      });
    }

    // 걸음 수 데이터 가져오기
    _fetchStepsForDate(selectedDate);
  }

  /// 실시간 걸음 수 업데이트 타이머 시작 (오늘 날짜인 경우에만)
  void _startStepUpdateTimer() {
    _stepUpdateTimer?.cancel();
    
    // 오늘 날짜인 경우에만 실시간 업데이트
    final isToday = _isToday(selectedDate);
    if (isToday && _hasHealthPermission) {
      _stepUpdateTimer = Timer.periodic(
        const Duration(seconds: 30), // 30초마다 업데이트
        (timer) async {
          if (mounted && _isToday(selectedDate)) {
            await _updateTodaySteps();
          } else {
            timer.cancel();
          }
        },
      );
    }
  }

  /// 오늘 날짜인지 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// 오늘의 걸음 수만 빠르게 업데이트
  Future<void> _updateTodaySteps() async {
    if (!_hasHealthPermission || !_isToday(selectedDate)) return;

    try {
      final deviceSteps = await _healthDataService.getTodaySteps();
      if (deviceSteps != _deviceSteps) {
        setState(() {
          // 기존 총합에서 이전 디바이스 걸음 수를 빼고 새로운 걸음 수 추가
          final difference = deviceSteps - _deviceSteps;
          _deviceSteps = deviceSteps;
          _totalSteps += difference;

          // 현재 사용자의 걸음 수 업데이트
          final currentUserInfo = PrefsManager.getUserInfo();
          currentUserInfo.then((userInfo) {
            final currentUserUuid = userInfo['uuid'];
            for (int i = 0; i < _memberSteps.length; i++) {
              if (_memberSteps[i].userId == currentUserUuid) {
                setState(() {
                  _memberSteps[i] = _MemberStep(
                    userId: _memberSteps[i].userId,
                    userName: _memberSteps[i].userName,
                    steps: deviceSteps,
                    imageAsset: _memberSteps[i].imageAsset,
                  );
                });
                break;
              }
            }
            // 걸음 수 순으로 다시 정렬
            _memberSteps.sort((a, b) => b.steps.compareTo(a.steps));
          });
        });

        // 서버에 업데이트
        try {
          await _stepService.uploadSteps(steps: deviceSteps);
        } catch (e) {
          print('실시간 걸음 수 서버 업로드 실패: $e');
        }
      }
    } catch (e) {
      print('실시간 걸음 수 업데이트 실패: $e');
    }
  }

  @override
  void dispose() {
    _stepUpdateTimer?.cancel();
    _dateCarouselController.dispose();
    super.dispose();
  }

  void _updateFromDateCarousel(DateTime date) {
    setState(() {
      selectedDate = DateTime(date.year, date.month, date.day);
    });
    _fetchStepsForDate(selectedDate);
    
    // 날짜가 변경되면 타이머 재시작 (오늘 날짜인 경우에만)
    if (_hasHealthPermission) {
      _startStepUpdateTimer();
    }
  }

  String _formatDate(DateTime date) {
    // yyyy-MM-dd
    return date.toIso8601String().split('T').first;
  }

  Future<void> _fetchStepsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String dateStr = _formatDate(date);

      // 1. 디바이스에서 Health 데이터 가져오기 (iOS)
      int deviceSteps = 0;
      if (_hasHealthPermission) {
        try {
          deviceSteps = await _healthDataService.getStepsForDate(date);
          print('디바이스 걸음 수: $deviceSteps');
        } catch (e) {
          print('디바이스 걸음 수 가져오기 실패: $e');
        }
      }

      // 2. 서버에서 가족 구성원 정보와 걸음 수 정보를 동시에 가져오기
      final List<Future> futures = [
        _stepService.getSteps(date: dateStr),
        FamilyService.getFamilyMembers(),
      ];

      final results = await Future.wait(futures);
      final Map<String, dynamic>? stepResult =
          results[0] as Map<String, dynamic>?;
      final List<Map<String, dynamic>> familyMembers =
          results[1] as List<Map<String, dynamic>>;

      // 3. 현재 사용자의 디바이스 걸음 수를 서버에 업로드
      if (_hasHealthPermission && deviceSteps > 0) {
        try {
          await _stepService.uploadSteps(steps: deviceSteps);
          print('걸음 수 서버 업로드 완료: $deviceSteps');
        } catch (e) {
          print('걸음 수 서버 업로드 실패: $e');
        }
      }

      int parsedTotal = 0;
      final List<_MemberStep> parsedMembers = [];
      
      if (stepResult != null) {
        if (stepResult['totalSteps'] is int) {
          parsedTotal = stepResult['totalSteps'] as int;
        } else if (stepResult['steps'] is int) {
          parsedTotal = stepResult['steps'] as int;
        } else if (stepResult['total'] is int) {
          parsedTotal = stepResult['total'] as int;
        }

        final dynamic members = stepResult['memberSteps'];
        if (members is List) {
          for (final dynamic item in members) {
            if (item is Map<String, dynamic>) {
              final String userId = (item['userId'] ?? '').toString();
              final String userName = (item['userName'] ?? '').toString();
              int steps = (item['steps'] is int)
                  ? item['steps'] as int
                  : int.tryParse(item['steps']?.toString() ?? '0') ?? 0;

              // 현재 사용자의 경우 디바이스 걸음 수로 업데이트
              final currentUserInfo = await PrefsManager.getUserInfo();
              final currentUserUuid = currentUserInfo['uuid'];
              if (userId == currentUserUuid && _hasHealthPermission && deviceSteps > 0) {
                steps = deviceSteps; // 디바이스 걸음 수 사용
              }

              // 더 향상된 사용자 매칭 로직
              String profileImagePath = await _getProfileImageForUser(
                userId,
                userName,
                familyMembers,
              );

              parsedMembers.add(
                _MemberStep(
                  userId: userId,
                  userName: userName.isEmpty ? '이름없음' : userName,
                  steps: steps,
                  imageAsset: profileImagePath,
                ),
              );
            }
          }
        }
      }

      // 현재 사용자가 서버 데이터에 없는 경우 추가
      if (_hasHealthPermission && deviceSteps > 0) {
        final currentUserInfo = await PrefsManager.getUserInfo();
        final currentUserUuid = currentUserInfo['uuid'];
        final currentUserName = currentUserInfo['name'] ?? '나';
        
        // 이미 존재하는지 확인
        final existingUser = parsedMembers
            .where((member) => member.userId == currentUserUuid)
            .firstOrNull;
            
        if (existingUser == null) {
          final profileImageId = currentUserInfo['profileImageId'] ?? 0;
          final profileImagePath = PrefsManager.getProfileImagePath(profileImageId);
          
          parsedMembers.add(
            _MemberStep(
              userId: currentUserUuid,
              userName: currentUserName,
              steps: deviceSteps,
              imageAsset: profileImagePath,
            ),
          );
        }
      }

      // 총 걸음 수 재계산 (디바이스 걸음 수 포함)
      if (_hasHealthPermission && deviceSteps > 0) {
        // 기존 총합에서 현재 사용자 걸음 수를 빼고 디바이스 걸음 수 추가
        final currentUserInfo = await PrefsManager.getUserInfo();
        final currentUserUuid = currentUserInfo['uuid'];
        
        final existingUserSteps = parsedMembers
            .where((member) => member.userId == currentUserUuid)
            .firstOrNull?.steps ?? 0;
            
        parsedTotal = parsedTotal - existingUserSteps + deviceSteps;
      }

      parsedMembers.sort((a, b) => b.steps.compareTo(a.steps));

      setState(() {
        _deviceSteps = deviceSteps;
        _totalSteps = parsedTotal;
        _memberSteps = parsedMembers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '걸음 수 조회 실패: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getProfileImageForUser(
    String userId,
    String userName,
    List<Map<String, dynamic>> familyMembers,
  ) async {
    try {
      // 1. userId로 매칭 시도 (uuid 필드와 비교)
      final memberByUuid = familyMembers
          .where((member) => member['uuid']?.toString() == userId)
          .firstOrNull;

      if (memberByUuid != null && memberByUuid['profileImageId'] != null) {
        return PrefsManager.getProfileImagePath(
          memberByUuid['profileImageId'] as int,
        );
      }

      // 2. userId 필드와 직접 비교
      final memberByUserId = familyMembers
          .where((member) => member['userId']?.toString() == userId)
          .firstOrNull;

      if (memberByUserId != null && memberByUserId['profileImageId'] != null) {
        return PrefsManager.getProfileImagePath(
          memberByUserId['profileImageId'] as int,
        );
      }

      // 3. userName으로 매칭 시도
      if (userName.isNotEmpty) {
        final memberByName = familyMembers
            .where((member) => member['name']?.toString() == userName)
            .firstOrNull;

        if (memberByName != null && memberByName['profileImageId'] != null) {
          return PrefsManager.getProfileImagePath(
            memberByName['profileImageId'] as int,
          );
        }
      }

      final currentUserInfo = await PrefsManager.getUserInfo();
      final currentUserUuid = currentUserInfo['uuid'];
      final currentUserName = currentUserInfo['name'];

      if (userId == currentUserUuid || userName == currentUserName) {
        final profileImageId = currentUserInfo['profileImageId'] ?? 0;
        return PrefsManager.getProfileImagePath(profileImageId);
      }

      return PrefsManager.getProfileImagePath(0);
    } catch (e) {
      return PrefsManager.getProfileImagePath(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return Scaffold(
      backgroundColor: AppColors.ongiLigntgrey,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -circleSize * 0.76),
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ongiOrange,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: circleSize * 0.86),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                '오늘 걸은 만큼 건강도 쌓였습니다.',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '잘하셨어요!',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                child: Image.asset(
                                  'assets/images/step_tracker_title_logo.png',
                                  width: circleSize * 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: circleSize * 0.4,
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 15,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // 본문 내용
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '오늘 우리 가족은',
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      height: 1.2,
                                      color: Color(0xFFFD6C01),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: '총 ',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: Color(0xFFFD6C01),
                                          ),
                                        ),
                                        TextSpan(
                                          text: _isLoading
                                              ? '0걸음'
                                              : '${_totalSteps
                                                        .toString()
                                                        .replaceAllMapped(
                                                          RegExp(
                                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                          ),
                                                          (m) => '${m[1]},',
                                                        )}걸음',
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 35,
                                            color: Color(0xFFFD6C01),
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' 걸었어요!',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: Color(0xFFFD6C01),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 85,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: DateCarousel(
                                        initialDate: selectedDate,
                                        controller: _dateCarouselController,
                                        onDateChanged: _updateFromDateCarousel,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else if (_isLoading && _memberSteps.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.ongiOrange,
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < _memberSteps.length; i++)
                                    _buildStepMember(
                                      context: context,
                                      name: _memberSteps[i].userName,
                                      steps: _memberSteps[i].steps,
                                      image: _memberSteps[i].imageAsset,
                                      isTop:
                                          i == 0 && _memberSteps[i].steps > 0,
                                    ),
                                  if (_memberSteps.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text('가족 걸음 데이터가 없습니다.'),
                                    ),
                                ],
                              ),
                          ],
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
    );
  }
}

class _MemberStep {
  final String userId;
  final String userName;
  final int steps;
  final String imageAsset;

  _MemberStep({
    required this.userId,
    required this.userName,
    required this.steps,
    required this.imageAsset,
  });
}

Widget _buildStepMember({
  required BuildContext context,
  required String name,
  required int steps,
  required String image,
  bool isTop = false,
}) {
  return Container(
    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 프로필 이미지 (pill 왼쪽)
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: 70, height: 80, child: Image.asset(image)),
            if (isTop)
              Positioned(
                left: -12,
                top: -15,
                child: SizedBox(
                  width: 42,
                  height: 32,
                  child: SvgPicture.asset(
                    'assets/images/step_tracker_crown.svg',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFD6C01),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Spacer(),
                    Text(
                      steps.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 40,
                        height: 0.7,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '걸음',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
