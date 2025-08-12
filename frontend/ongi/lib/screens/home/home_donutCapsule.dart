import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/custom_chart_painter.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/services/temperature_service.dart';
import 'package:ongi/services/health_service.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/services/step_service.dart';

class HomeCapsuleSection extends StatefulWidget {
  final VoidCallback? onGraphTap;
  final VoidCallback? onRefresh;
  const HomeCapsuleSection({super.key, this.onGraphTap, this.onRefresh});

  @override
  State<HomeCapsuleSection> createState() => _HomeCapsuleSectionState();
}

class _HomeCapsuleSectionState extends State<HomeCapsuleSection> {
  double? todayTemperature;
  bool isLoading = true;
  final GlobalKey<_ButtonColumnState> _buttonColumnKey =
      GlobalKey<_ButtonColumnState>();

  @override
  void initState() {
    super.initState();
    fetchTodayTemperature();
  }

  // 전체 데이터 새로고침
  void refreshAllData() {
    fetchTodayTemperature();
    _buttonColumnKey.currentState?.refreshData();
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  Future<void> fetchTodayTemperature() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      if (familyCode == null) throw Exception('가족 코드가 없습니다.');
      final token = await PrefsManager.getAccessToken();
      final service = TemperatureService(
        baseUrl: 'https://ongi-1049536928483.asia-northeast3.run.app',
      );
      final dailyTemps = await service.fetchFamilyTemperatureDaily(
        familyCode,
        token: token,
      );
      double latestTotalTemperature;
      if (dailyTemps.isEmpty) {
        latestTotalTemperature = 36.5;
      } else {
        final lastEntry = dailyTemps.last;
        latestTotalTemperature =
            ((lastEntry['totalTemperature'] as num?)?.toDouble()) ?? 36.5;
      }
      setState(() {
        todayTemperature = latestTotalTemperature;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        todayTemperature = 36.5;
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
                            percentages: [15, 10, 20, 20],
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
                        ? const CircularProgressIndicator()
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

class _ButtonColumnState extends State<ButtonColumn> {
  int selectedIdx = -1; // 초기값을 -1로 (아무것도 선택되지 않은 상태)

  // API 데이터 상태
  String pillText = '';
  String painText = '';
  String stepText = '';
  bool isLoading = true;

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
    _loadData();
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
      final pillSchedule = await PillService.getTodayPillSchedule();
      print('약물 데이터 응답: $pillSchedule');
      if (pillSchedule.isNotEmpty) {
        // 첫 번째 약물 정보 사용
        final pill = pillSchedule.first;
        final pillName = pill['name'] ?? '약물';
        final intakeTimes = pill['intakeTimes'] as List<dynamic>? ?? [];

        if (intakeTimes.isNotEmpty) {
          // 다음 복용 시간 찾기
          final now = DateTime.now();
          final currentTime = TimeOfDay.fromDateTime(now);

          TimeOfDay? nextIntakeTime;
          for (final timeStr in intakeTimes) {
            final time = TimeOfDay(
              hour: int.parse(timeStr.split(':')[0]),
              minute: int.parse(timeStr.split(':')[1]),
            );

            // 현재 시간보다 늦은 시간 찾기
            if (time.hour > currentTime.hour ||
                (time.hour == currentTime.hour &&
                    time.minute > currentTime.minute)) {
              nextIntakeTime = time;
              break;
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
        pillText = '오늘의 복용 약'; // 기본값
      });
    }
  }

  // 통증 부위 코드를 한글로 변환하는 함수
  String _convertPainAreaToKorean(String painArea) {
    final Map<String, String> painAreaMap = {
      'head': '머리',
      'neck': '목',
      'shoulder': '어깨',
      'arm': '팔',
      'chest': '가슴',
      'back': '등',
      'waist': '허리',
      'hip': '엉덩이',
      'leg': '다리',
      'knee': '무릎',
      'ankle': '발목',
      'foot': '발',
      'stomach': '배',
      'wrist': '손목',
      'hand': '손',
      'elbow': '팔꿈치',
      'thigh': '허벅지',
      'calf': '종아리',
      'spine': '척추',
      'pelvis': '골반',
    };

    return painAreaMap[painArea.toLowerCase()] ?? painArea;
  }

  Future<void> _loadPainData() async {
    try {
      print('통증 데이터 로딩 시작');
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
              .map(
                (record) =>
                    _convertPainAreaToKorean(record['painArea'].toString()),
              )
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
        painText = '오늘의 통증 부위'; // 기본값
      });
    }
  }

  Future<void> _loadStepData() async {
    try {
      print('걸음 수 데이터 로딩 시작');
      final totalSteps = await StepService.getTodayTotalSteps();
      print('걸음 수 응답: $totalSteps');
      setState(() {
        stepText =
            '${totalSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 걸음';
      });
    } catch (e) {
      print('걸음 수 데이터 로딩 오류: $e');
      setState(() {
        stepText = '오늘의 걸음'; // 기본값
      });
    }
  }

  // 외부에서 호출할 수 있는 새로고침 메서드
  void refreshData() {
    _loadData();
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
