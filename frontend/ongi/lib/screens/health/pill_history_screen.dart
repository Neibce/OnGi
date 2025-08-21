import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'add_pill_screen.dart';

class PillHistoryScreen extends StatefulWidget {
  final String? selectedParentId;
  final bool? isChild;
  
  const PillHistoryScreen({
    super.key,
    this.selectedParentId,
    this.isChild,
  });

  @override
  State<PillHistoryScreen> createState() => _PillHistoryScreenState();
}

class _PillHistoryScreenState extends State<PillHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todaySchedule = <Map<String, dynamic>>[];
  final Set<String> _takenKeys = <String>{};
  DateTime _selectedDate = DateTime.now();
  
  // 자녀 사용자 관련 상태
  bool _isChild = false;
  String? _selectedParentId;
  
  // 약 복용 상태 관련
  int _todayPillCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void didUpdateWidget(PillHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 부모가 변경되었을 때 데이터 다시 로드
    if (widget.selectedParentId != oldWidget.selectedParentId) {
      setState(() {
        _selectedParentId = widget.selectedParentId;
      });
      _fetchTodaySchedule();
    }
  }

  Future<void> _initializeScreen() async {
    // 이전 화면에서 전달받은 정보가 있으면 사용
    if (widget.isChild != null && widget.selectedParentId != null) {
      setState(() {
        _isChild = widget.isChild!;
        _selectedParentId = widget.selectedParentId;
      });
    }
    
    _fetchTodaySchedule();
  }

  Future<void> _fetchTodaySchedule() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 자녀인 경우 선택된 부모의 약 정보 조회
      final List<Map<String, dynamic>> schedule =
          await PillService.getPillScheduleByDate(_selectedDate, parentUuid: _selectedParentId);
      final Set<String> taken = <String>{};
      for (final pill in schedule) {
        final dynamic idRaw = pill['id'] ?? pill['pillId'] ?? pill['pillID'];
        final String pillId = idRaw?.toString() ?? '';
        if (pillId.isEmpty) continue;
        final Map<String, dynamic> status = Map<String, dynamic>.from(
          pill['dayIntakeStatus'] ?? {},
        );
        for (final String scheduled in status.keys) {
          final String hhmm = scheduled.length >= 5
              ? scheduled.substring(0, 5)
              : scheduled;
          taken.add('$pillId|$hhmm');
        }
      }
      // 약 복용 카운트 계산
      int totalIntakes = 0;
      int takenIntakes = 0;
      
      for (var pill in schedule) {
        final List<dynamic> intakeTimes = pill['intakeTimes'] ?? [];
        final Map<String, dynamic> dayIntakeStatus = pill['dayIntakeStatus'] ?? {};
        
        totalIntakes += intakeTimes.length;
        
        // dayIntakeStatus에서 실제 복용한 시간들을 확인
        for (var intakeTime in intakeTimes) {
          final timeKey = intakeTime.toString().substring(0, 5); // "08:00:00" -> "08:00"
          if (dayIntakeStatus.containsKey(timeKey)) {
            takenIntakes++;
          }
        }
      }
      
      // 남은 복용 횟수
      int remainingIntakes = totalIntakes - takenIntakes;
      if (remainingIntakes < 0) remainingIntakes = 0;

      setState(() {
        _todaySchedule = schedule;
        _takenKeys
          ..clear()
          ..addAll(taken);
        _todayPillCount = remainingIntakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _todaySchedule = <Map<String, dynamic>>[];
        _todayPillCount = 0;
        _isLoading = false;
      });
    }
  }

  String _displayTime(String raw) {
    if (raw.length >= 5) {
      return raw.substring(0, 5);
    }
    return raw;
  }

  String _mapIntakeDetailToKorean(String label) {
    switch (label) {
      case 'BEFORE_MEAL_30MIN':
        return '식전 30분';
      case 'AFTER_MEAL_30MIN':
        return '식후 30분 이내';
      case 'AFTER_MEAL_60MIN':
        return '식후 1시간';
      case 'BEFORE_SLEEP':
        return '취침 전';
      case 'ANYTIME':
        return '상관없음';
      default:
        return '';
    }
  }

  Widget _buildPillStatusText() {
    if (_todayPillCount == 0) {
      return const Column(
        children: [
          Text(
            '오늘의 약을',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(
            '모두 섭취하셨어요!',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Text(
            _isChild ? '오늘 ${_todayPillCount}개의 약을' : '오늘 복용해야 할 약,',
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(
            _isChild ? '섭취하지 않으셨어요!' : '다 섭취 하셨나요?',
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  Future<void> _addRecord({
    required String pillId,
    required String intakeTime,
  }) async {
    final String key = '$pillId|${_displayTime(intakeTime)}';
    
    // 즉시 UI 업데이트 (서버 응답 전)
    setState(() {
      _takenKeys.add(key);
      if (_todayPillCount > 0) _todayPillCount--;
    });
    
    try {
      await PillService.addPillRecord(
        pillId: pillId,
        intakeTime: intakeTime,
        intakeDate: _selectedDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '복용 기록이 추가되었습니다.',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 서버 요청 실패 시 UI 상태 롤백
      setState(() {
        _takenKeys.remove(key);
        _todayPillCount++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복용 기록 추가 실패: $e',
            style: const TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteRecord({
    required String pillId,
    required String intakeTime,
  }) async {
    final String key = '$pillId|${_displayTime(intakeTime)}';
    
    // 즉시 UI 업데이트 (서버 응답 전)
    setState(() {
      _takenKeys.remove(key);
      _todayPillCount++;
    });
    
    try {
      await PillService.deletePillRecord(
        pillId: pillId,
        intakeTime: intakeTime,
        intakeDate: _selectedDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '복용 기록이 취소되었습니다.',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 서버 요청 실패 시 UI 상태 롤백
      setState(() {
        _takenKeys.add(key);
        if (_todayPillCount > 0) _todayPillCount--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복용 기록 취소 실패: $e',
            style: const TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deletePill(String pillId, String pillName) async {
    // 확인 다이얼로그 표시
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '약 삭제',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            '$pillName을(를) 삭제하시겠습니까?\n삭제된 약은 복구할 수 없습니다.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: AppColors.ongiOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    // 즉시 UI에서 제거 (낙관적 업데이트)
    setState(() {
      _todaySchedule.removeWhere((pill) {
        final dynamic idRaw = pill['id'] ?? pill['pillId'] ?? pill['pillID'];
        return idRaw?.toString() == pillId;
      });
      // 해당 약의 복용 기록도 제거
      _takenKeys.removeWhere((key) => key.startsWith('$pillId|'));
      // 남은 복용 횟수 재계산
      _recalculatePillCount();
    });

    try {
      await PillService.deletePill(pillId);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '약이 삭제되었습니다.',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 서버 요청 실패 시 데이터 복원
      _fetchTodaySchedule();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '약 삭제 실패: $e',
            style: const TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _recalculatePillCount() {
    int totalIntakes = 0;
    int takenIntakes = 0;
    
    for (var pill in _todaySchedule) {
      final List<dynamic> intakeTimes = pill['intakeTimes'] ?? [];
      final Map<String, dynamic> dayIntakeStatus = pill['dayIntakeStatus'] ?? {};
      
      totalIntakes += intakeTimes.length;
      
      // dayIntakeStatus에서 실제 복용한 시간들을 확인
      for (var intakeTime in intakeTimes) {
        final timeKey = intakeTime.toString().substring(0, 5); // "08:00:00" -> "08:00"
        if (dayIntakeStatus.containsKey(timeKey)) {
          takenIntakes++;
        }
      }
    }
    
    // 남은 복용 횟수
    int remainingIntakes = totalIntakes - takenIntakes;
    if (remainingIntakes < 0) remainingIntakes = 0;
    
    _todayPillCount = remainingIntakes;
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
                        padding: EdgeInsets.only(top: circleSize * 0.815),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              _buildPillStatusText(),
                              Image.asset(
                                'assets/images/pill_history_title_logo.png',
                                width: circleSize * 0.26,
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
              top: circleSize * 0.3 + 105,
              left: 0,
              right: 0,
              bottom: 0,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.ongiOrange,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchTodaySchedule,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        itemCount: _todaySchedule.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _todaySchedule.length) {
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPillScreen(
                                      targetParentId: _selectedParentId,
                                    ),
                                  ),
                                );
                                
                                // 약 추가 성공 시 즉시 새로고침
                                if (result == true) {
                                  print('약 추가 성공 - 즉시 데이터 새로고침');
                                  // 즉시 새로고침
                                  _fetchTodaySchedule();
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.pillsAddItemBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppColors.pillsAddItemBackgroundDark,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: SvgPicture.asset(
                                        'assets/images/add_icon.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final Map<String, dynamic> pill =
                              _todaySchedule[index];
                          final dynamic idRaw =
                              pill['id'] ?? pill['pillId'] ?? pill['pillID'];
                          final String pillId = idRaw?.toString() ?? '';
                          final String pillName = (pill['name'] ?? '약물')
                              .toString();
                          final String? imageUrl = pill['imageUrl']?.toString();
                          final String intakeDetail = _mapIntakeDetailToKorean(
                            pill['intakeDetail'],
                          ).toString();
                          // (pill['intakeDetail'] ?? '').toString();
                          final List<dynamic> timesDyn =
                              pill['intakeTimes'] as List<dynamic>? ??
                              <dynamic>[];
                          final List<String> times = timesDyn
                              .map((e) => e.toString())
                              .toList()
                              ..sort((a, b) {
                                // 시간 문자열을 DateTime으로 변환해서 정렬
                                try {
                                  final timeA = DateTime.parse('2000-01-01 $a:00');
                                  final timeB = DateTime.parse('2000-01-01 $b:00');
                                  return timeA.compareTo(timeB);
                                } catch (e) {
                                  return a.compareTo(b);
                                }
                              });
                          final int timesCount = times.length;

                          // 카드
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pillsItemBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: imageUrl != null && imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 38,
                                                  height: 38,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    // 이미지 로드 실패 시 기본 아이콘 표시
                                                    return SvgPicture.asset(
                                                      'assets/images/pill_item_icon.svg',
                                                      width: 38,
                                                      height: 38,
                                                    );
                                                  },
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                'assets/images/pill_item_icon.svg',
                                                width: 38,
                                                height: 38,
                                              ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                pillName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '매일, ${timesCount}회${intakeDetail.isNotEmpty ? ', $intakeDetail' : ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double availableWidth = constraints.maxWidth;
                                          
                                          // 버튼 개수에 따른 너비 계산
                                          double buttonWidth;
                                          if (times.length <= 2) {
                                            // 1-2개: 각각 1/3 비율 (약간의 여백 고려)
                                            buttonWidth = (availableWidth - 16) / 3;
                                          } else if (times.length == 3) {
                                            // 3개: 각각 1/3 비율 (약간의 여백 고려)
                                            buttonWidth = (availableWidth - 32) / 3;
                                          } else if (times.length == 4) {
                                            // 4개: 각각 1/4 비율
                                            buttonWidth = (availableWidth - 48) / 4;
                                          } else {
                                            // 5개 이상: 각각 1/5 비율
                                            buttonWidth = (availableWidth - 64) / 5;
                                          }
                                          
                                          return Wrap(
                                            alignment: times.length <= 2 
                                              ? WrapAlignment.start 
                                              : WrapAlignment.spaceEvenly,
                                            children: times.map((timeStr) {
                                              final String key =
                                                  '$pillId|${_displayTime(timeStr)}';
                                              final bool taken = _takenKeys
                                                  .contains(key);
                                              
                                              return Container(
                                                width: buttonWidth,
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                  bottom: 4,
                                                ),
                                                child: GestureDetector(
                                                  onTap: (_isChild || pillId.isEmpty)
                                                      ? null
                                                      : () {
                                                          if (taken) {
                                                            _deleteRecord(
                                                              pillId: pillId,
                                                              intakeTime: timeStr,
                                                            );
                                                          } else {
                                                            _addRecord(
                                                              pillId: pillId,
                                                              intakeTime: timeStr,
                                                            );
                                                          }
                                                        },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: taken
                                                          ? Colors.white
                                                          : AppColors.ongiOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _displayTime(timeStr),
                                                        style: TextStyle(
                                                          color: taken
                                                              ? Colors.black
                                                              : Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                          ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 제거 버튼 추가
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _deletePill(pillId, pillName),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.ongiOrange,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Positioned(
              top: circleSize * 0.3 + 40,
              left: 0,
              right: 0,
              child: DateCarousel(
                onDateChanged: (date) {
                  final DateTime justDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                  if (justDate.isAtSameMomentAs(_selectedDate)) return;
                  _selectedDate = justDate;
                  _takenKeys.clear();
                  _fetchTodaySchedule();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
