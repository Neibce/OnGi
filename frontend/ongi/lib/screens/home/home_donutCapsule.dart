import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/custom_chart_painter.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/services/temperature_service.dart';
import 'package:ongi/services/health_service.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/services/step_service.dart';
import 'package:ongi/services/family_service.dart';
import 'package:ongi/services/temperature_summary_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeCapsuleSection extends StatefulWidget {
  final VoidCallback? onGraphTap;
  final VoidCallback? onRefresh;
  const HomeCapsuleSection({super.key, this.onGraphTap, this.onRefresh});

  @override
  State<HomeCapsuleSection> createState() => _HomeCapsuleSectionState();
}

class _HomeCapsuleSectionState extends State<HomeCapsuleSection> {
  String? _token;
  double? todayTemperature;
  bool isLoading = true;
  List<double> memberContributions = []; // 가족 구성원의 온도 기여도 비율
  final GlobalKey<_ButtonColumnState> _buttonColumnKey =
      GlobalKey<_ButtonColumnState>();

  @override
  void initState() {
    super.initState();
    _initializeToken().then((_) {
      fetchTodayTemperature();
      fetchTemperatureSummary(); // 온도 요약 정보
    }).catchError((error) {
      print('초기화 실패: $error');
    });
  }

  Future<void> _initializeToken() async {
    _token = await PrefsManager.getAccessToken();
    if (_token == null) {
      throw Exception('토큰을 가져올 수 없습니다.');
    }
  }


  // 전체 데이터 새로고침
  void refreshAllData() {
    print('HomeCapsuleSection 전체 데이터 새로고침');
    fetchTodayTemperature();
    _buttonColumnKey.currentState?.refreshData();
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  // 약물 데이터만 새로고침
  void refreshPillDataOnly() {
    print('HomeCapsuleSection 약물 데이터만 새로고침');
    _buttonColumnKey.currentState?.refreshPillDataOnly();
  }

  Future<void> fetchTodayTemperature() async {
    if (_token == null) {
      print('토큰이 없습니다.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      if (familyCode == null || familyCode.isEmpty) {
        throw Exception('가족 코드를 가져올 수 없습니다.');
      }

      final service = TemperatureService(
        baseUrl: 'https://ongi-1049536928483.asia-northeast3.run.app',
      );
      final dailyTemps = await service.fetchFamilyTemperatureDaily(
        familyCode,
        token: _token!,
      );

      double latestTotalTemperature = dailyTemps.isNotEmpty
          ? ((dailyTemps.last['totalTemperature'] as num?)?.toDouble() ?? 36.5)
          : 36.5;

      setState(() {
        todayTemperature = latestTotalTemperature;
        isLoading = false;
      });
    } catch (e) {
      print('온도 조회 실패: $e');
      setState(() {
        todayTemperature = 36.5;
        isLoading = false;
      });
    }
  }

  Future<void> fetchTemperatureSummary() async {
    if (_token == null) {
      print('토큰이 없습니다.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      if (familyCode == null || familyCode.isEmpty) {
        throw Exception('가족 코드를 가져올 수 없습니다.');
      }

      final service = TemperatureSummaryService();
      final summary = await service.fetchTemperatureSummary(familyCode, _token!);
      print('API 응답 데이터: $summary');


      final List<dynamic> memberIncreaseTemperatures =
          summary['memberIncreaseTemperatures'] ?? [];
      final double totalIncreaseTemperature =
          summary['totalFamilyIncreaseTemperature'] ?? 0;

      setState(() {
        // 1. 개인 기여도만 계산: userId가 null이 아닌 데이터만 처리
        // 2. 긍정적인 기여도만 계산
        double positiveTotalIncreaseTemperature = 0;

        memberContributions = memberIncreaseTemperatures
            .where((value) {
          // userId가 null인 항목은 제외
          final userId = value['userId'];
          final contributedTemperature = value['contributedTemperature'] as num;

          // 온도 상승만 반영 (기여도는 양수일 때만 반영)
          return userId != null && contributedTemperature > 0;
        })
            .map((value) {
          final contributedTemperature = value['contributedTemperature'] as num;
          positiveTotalIncreaseTemperature += contributedTemperature;
          return contributedTemperature.toDouble();
        })
            .toList();

        // 3. 전체 긍정적 기여도 합계가 0인 경우, 모든 기여도를 0%로 설정 ; 기본 설정 시
        if (positiveTotalIncreaseTemperature > 0) {
          memberContributions = memberContributions
              .map((contributedTemperature) {
            // 기여도를 전체 기여도 합계로 나누어 퍼센트를 계산
            double percentage = (contributedTemperature / positiveTotalIncreaseTemperature) * 100;
            return double.parse(percentage.toStringAsFixed(2)); // 소수점 2자리로 반올림
          })
              .toList();
        } else {
          // 기여도가 없을 경우 모든 기여도 0%로 설정
          memberContributions = List.generate(memberIncreaseTemperatures.length, (_) => 0.0);
        }

        print('memberContributions: $memberContributions');
        isLoading = false;
      });
    } catch (e) {
      print('온도 요약 정보 조회 실패: $e');
      setState(() {
        memberContributions = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // 도넛 차트 영역
          Positioned(
            left: 0,
            bottom: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.95,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: widget.onGraphTap,
                    child: Transform.translate(
                      offset: Offset(
                        -MediaQuery.of(context).size.width * 0.35,
                        0,
                      ),
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: CustomPaint(
                          painter: CustomChartPainter(
                            percentages: memberContributions.isNotEmpty
                                ? memberContributions
                                : [1.0], // 데이터가 없으면 전체를 하나로 표시
                          ),
                          size: Size(
                            MediaQuery.of(context).size.width * 0.95,
                            MediaQuery.of(context).size.width * 0.95,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 텍스트 (화면 안에 있음)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.04,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.ongiOrange,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                todayTemperature?.toStringAsFixed(1) ?? '36.5',
                                style: TextStyle(
                                  fontSize: 43,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ongiOrange,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '℃',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ongiOrange,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: ButtonColumn(key: _buttonColumnKey),
          ),
        ],
      ),
    );
  }
}

class CapsuleButton extends StatelessWidget {
  final String svgAsset;
  final bool selected;
  final VoidCallback onTap;
  final String notificationText;

  const CapsuleButton({
    required this.svgAsset,
    required this.selected,
    required this.onTap,
    required this.notificationText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: MediaQuery.of(context).size.width * 0.18,
        width: selected
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.17,
        margin: const EdgeInsets.only(top: 2, bottom: 2, left: 0, right: 0),
        decoration: BoxDecoration(
          color: selected ? AppColors.ongiOrange : AppColors.ongiLigntgrey,
          border: Border(
            top: BorderSide(color: AppColors.ongiOrange, width: 2),
            bottom: BorderSide(color: AppColors.ongiOrange, width: 2),
            left: BorderSide(color: AppColors.ongiOrange, width: 2),
            right: BorderSide.none,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(39),
            bottomLeft: Radius.circular(39),
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.ongiOrange, offset: Offset(0, 4))]
              : [],
        ),
        // ↓↓↓ 여기 추가!
        child: Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: const Offset(0, 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                SvgPicture.asset(
                  svgAsset,
                  width: MediaQuery.of(context).size.width * 0.07,
                  height: MediaQuery.of(context).size.width * 0.07,
                  alignment: Alignment.center,
                  color: selected ? Colors.white : AppColors.ongiOrange,
                ),
                if (selected && notificationText.isNotEmpty) ...[
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          notificationText,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonColumn extends StatefulWidget {
  const ButtonColumn({super.key});

  @override
  State<ButtonColumn> createState() => _ButtonColumnState();
}

class _ButtonColumnState extends State<ButtonColumn> with WidgetsBindingObserver {
  int selectedIdx = -1; // 초기값을 -1로 (아무것도 선택되지 않은 상태)

  // API 데이터 상태
  String pillText = '';
  String painText = '';
  String stepText = '';
  bool isLoading = true;

  // 자녀 사용자 관련 상태
  bool _isChild = false;
  List<Map<String, dynamic>> _parentMembers = [];

  String _formatRemaining(Duration d) {
    if (d.inMinutes <= 0) return '곧';
    if (d.inMinutes >= 60) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return m == 0 ? '$h시간 뒤' : '$h시간 ${m}분 뒤';
    }
    return '${d.inMinutes}분 뒤';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final isParent = await PrefsManager.getIsParent();
      _isChild = !isParent;

      if (_isChild) {
        await _loadParentMembers();
      }

      _loadData();
    } catch (e) {
      print('사용자 타입 확인 실패: $e');
      _loadData(); // 오류 시 기본 동작
    }
  }

  Future<void> _loadParentMembers() async {
    try {
      final members = await FamilyService.getFamilyMembers();
      final parents = members.where((member) => member['isParent'] == true).toList();
      setState(() {
        _parentMembers = parents;
      });
    } catch (e) {
      print('부모 멤버 로드 실패: $e');
    }
  }

  Future<void> _loadNearestParentPillInfo() async {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);

      String? nearestParentName;
      String? nearestPillName;
      Duration? shortestDuration;

      for (final parent in _parentMembers) {
        try {
          final parentUuid = parent['uuid'];
          final parentName = parent['name'] ?? '부모님';

          if (parentUuid != null) {
            final pillSchedule = await PillService.getTodayPillSchedule(parentUuid: parentUuid)
                .timeout(const Duration(seconds: 5));

            for (final pill in pillSchedule) {
              final pillName = pill['name'] ?? '약물';
              final intakeTimes = pill['intakeTimes'] as List<dynamic>? ?? [];

              for (final timeStr in intakeTimes) {
                try {
                  final timeParts = timeStr.toString().split(':');
                  if (timeParts.length >= 2) {
                    final time = TimeOfDay(
                      hour: int.parse(timeParts[0]),
                      minute: int.parse(timeParts[1]),
                    );

                    // 현재 시간보다 늦은 시간인지 확인
                    if (time.hour > currentTime.hour ||
                        (time.hour == currentTime.hour && time.minute > currentTime.minute)) {

                      final nextDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        time.hour,
                        time.minute,
                      );
                      final difference = nextDateTime.difference(now);

                      // 가장 가까운 시간인지 확인
                      if (shortestDuration == null || difference < shortestDuration) {
                        shortestDuration = difference;
                        nearestParentName = parentName;
                        nearestPillName = pillName;
                      }
                    }
                  }
                } catch (timeParseError) {
                  print('시간 파싱 오류: $timeParseError, 시간: $timeStr');
                }
              }
            }
          }
        } catch (e) {
          print('부모 ${parent['name']} 약물 데이터 로딩 오류: $e');
        }
      }

      // 결과 설정
      if (nearestParentName != null && nearestPillName != null && shortestDuration != null) {
        final remain = _formatRemaining(shortestDuration);
        setState(() {
          pillText = '$nearestParentName님은 $remain $nearestPillName을 먹어야 해요';
        });
      } else {
        setState(() {
          pillText = '부모님 약 복용 시간을 확인해봐요';
        });
      }
    } catch (e) {
      print('가장 가까운 부모 약물 정보 로딩 오류: $e');
      setState(() {
        pillText = '부모님 약 복용 시간을 확인해봐요';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 다시 포그라운드로 돌아올 때 즉시 약물 데이터만 새로고침
    if (state == AppLifecycleState.resumed) {
      print('앱이 다시 포그라운드로 돌아옴 - 약물 데이터 즉시 새로고침');
      // 약물 데이터만 빠르게 새로고침
      _loadPillData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 병렬로 데이터 로드
      final futures = await Future.wait([
        _loadPillData(),
        _loadPainData(),
        _loadStepData(),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('데이터 로드 중 오류: $e');
    }
  }

  Future<void> _loadPillData() async {
    try {
      print('약물 데이터 로딩 시작');

      if (_isChild) {
        // 자녀 화면: 가장 가까운 시간에 약을 복용해야 하는 부모 찾기
        await _loadNearestParentPillInfo();
        return;
      }

      // 부모 화면: 기존 로직 유지
      final userInfo = await PrefsManager.getUserInfo();
      final parentUuid = userInfo['uuid'];

      if (parentUuid == null) {
        print('사용자 UUID가 없습니다');
        setState(() {
          pillText = '사용자 정보 없음';
        });
        return;
      }

      print('사용자 UUID: $parentUuid');

      final pillSchedule = await PillService.getTodayPillSchedule(parentUuid: parentUuid)
          .timeout(const Duration(seconds: 5));

      print('약물 데이터 응답: $pillSchedule');
      print('약물 데이터 개수: ${pillSchedule.length}');

      if (pillSchedule.isNotEmpty) {
        // 첫 번째 약물 정보 사용ㅅㄹ
        final pill = pillSchedule.first;
        final pillName = pill['name'] ?? '약물';
        final intakeTimes = pill['intakeTimes'] as List<dynamic>? ?? [];

        print('약물 이름: $pillName');
        print('복용 시간들: $intakeTimes');
        print('복용 시간 타입: ${intakeTimes.runtimeType}');

        if (intakeTimes.isNotEmpty) {
          // 다음 복용 시간 찾기
          final now = DateTime.now();
          final currentTime = TimeOfDay.fromDateTime(now);

          TimeOfDay? nextIntakeTime;
          for (final timeStr in intakeTimes) {
            try {
              // 시간 문자열 파싱
              final timeParts = timeStr.toString().split(':');
              if (timeParts.length >= 2) {
                final time = TimeOfDay(
                  hour: int.parse(timeParts[0]),
                  minute: int.parse(timeParts[1]),
                );

                // 현재 시간보다 늦은 시간 찾기
                if (time.hour > currentTime.hour ||
                    (time.hour == currentTime.hour &&
                        time.minute > currentTime.minute)) {
                  nextIntakeTime = time;
                  break;
                }
              }
            } catch (timeParseError) {
              print('시간 파싱 오류: $timeParseError, 시간: $timeStr');
            }
          }

          if (nextIntakeTime != null) {
            final nextDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              nextIntakeTime.hour,
              nextIntakeTime.minute,
            );
            final difference = nextDateTime.difference(now);
            final remain = _formatRemaining(difference);
            setState(() {
              pillText = '$remain, $pillName 복용 예정';
            });
          } else {
            setState(() {
              pillText = '$pillName 복용 완료';
            });
          }
        } else {
          setState(() {
            pillText = '$pillName 등록됨';
          });
        }
      } else {
        setState(() {
          pillText = '등록된 약이 없습니다';
        });
      }
    } catch (e) {
      print('약물 데이터 로딩 오류: $e');
      setState(() {
        pillText = '약물 정보 로드 실패';
      });
    }
  }

  // 통증 부위 코드를 한글로 변환하는 함수
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


  Future<void> _loadPainData() async {
    try {
      print('통증 데이터 로딩 시작');

      if (_isChild) {
        // 자녀 화면: 부모들의 통증 기록 확인
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        List<String> painfulParents = [];

        for (final parent in _parentMembers) {
          try {
            final parentId = parent['uuid'];
            if (parentId != null) {
              final painRecords = await HealthService.fetchPainRecords(parentId);
              final todayPainRecords = painRecords
                  .where((record) => record['date'] == todayStr)
                  .toList();

              if (todayPainRecords.isNotEmpty) {
                final parentName = parent['name'] ?? '부모님';
                final koreanAreas = todayPainRecords
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
                painfulParents.add('$parentName님이 $koreanAreas가 아파요');
              }
            }
          } catch (e) {
            print('부모 ${parent['name']} 통증 데이터 로딩 오류: $e');
          }
        }

        if (painfulParents.isNotEmpty) {
          setState(() {
            painText = painfulParents.first; // 첫 번째 부모의 통증 정보만 표시
          });
        } else {
          setState(() {
            painText = '오늘은 아픈 곳이 없으시네요';
          });
        }
        return;
      }

      // 부모 화면: 기존 로직 유지
      final userInfo = await PrefsManager.getUserInfo();
      final userId = userInfo['uuid'];
      print('사용자 ID: $userId');
      if (userId != null) {
        final painRecords = await HealthService.fetchPainRecords(userId);
        print('통증 데이터 응답: $painRecords');

        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final todayPainRecords = painRecords
            .where((record) => record['date'] == todayStr)
            .toList();

        if (todayPainRecords.isNotEmpty) {
          final koreanAreas = todayPainRecords
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
          setState(() {
            painText = '오늘의 통증 부위: $koreanAreas';
          });
        } else {
          setState(() {
            painText = '오늘 통증 기록이 없습니다';
          });
        }
      }
    } catch (e) {
      print('통증 데이터 로딩 오류: $e');
      setState(() {
        painText = _isChild ? '통증 정보 확인 중...' : '오늘의 통증 부위'; // 기본값
      });
    }
  }

  Future<void> _loadStepData() async {
    try {
      print('걸음 수 데이터 로딩 시작');
      final totalSteps = await StepService.getTodayTotalSteps();
      print('걸음 수 응답: $totalSteps');
      setState(() {
        if (_isChild) {
          stepText = '오늘 ${totalSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 걸음 걸었어요';
        } else {
          stepText = '${totalSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 걸음';
        }
      });
    } catch (e) {
      print('걸음 수 데이터 로딩 오류: $e');
      setState(() {
        stepText = _isChild ? '내 걸음 수' : '오늘의 걸음'; // 기본값
      });
    }
  }

  // 외부에서 호출할 수 있는 새로고침 메서드
  void refreshData() {
    print('ButtonColumn 강제 새로고침 호출됨');
    _loadData();
  }

  // 약물 데이터만 빠르게 새로고침
  void refreshPillDataOnly() {
    print('약물 데이터만 빠르게 새로고침');
    _loadPillData();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // overflow 방지
        crossAxisAlignment: CrossAxisAlignment.end, // 오른쪽 정렬
        children: [
          CapsuleButton(
            svgAsset: 'assets/images/homebar_capsule.svg',
            selected: selectedIdx == 0,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 0 ? -1 : 0),
            notificationText: selectedIdx == 0
                ? (isLoading ? '로딩 중...' : pillText)
                : '',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_med.svg',
            selected: selectedIdx == 1,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 1 ? -1 : 1),
            notificationText: selectedIdx == 1
                ? (isLoading ? '로딩 중...' : painText)
                : '',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_walk.svg',
            selected: selectedIdx == 2,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 2 ? -1 : 2),
            notificationText: selectedIdx == 2
                ? (isLoading ? '로딩 중...' : stepText)
                : '',
          ),
        ],
      ),
    );
  }
}