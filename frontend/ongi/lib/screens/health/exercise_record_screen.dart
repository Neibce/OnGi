import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/screens/health/exercise_record_detail_screen.dart';
import 'package:ongi/services/exercise_service.dart';

enum _TriggerSource { none, button, swipe }

class ExerciseRecordScreen extends StatefulWidget {
  final String? selectedParentId;
  final bool? isChild;

  const ExerciseRecordScreen({super.key, this.selectedParentId, this.isChild});

  @override
  State<ExerciseRecordScreen> createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends State<ExerciseRecordScreen> {
  static const int _centerPage = 5000;

  late final DateTime referenceDate; // normalized "today" at midnight
  DateTime selectedDate = DateTime.now();

  late final PageController _exercisePageController;
  late final PageController _dateCarouselController;

  _TriggerSource _triggerSource = _TriggerSource.none;

  // Store exercise times for different dates; key is yyyy-MM-dd
  Map<String, Map<String, int>> exerciseTimes = {};

  // SharedPreferences key
  static const String _exerciseTimesKey = 'exercise_times';

  // 자녀용 상태 관리
  bool _isChild = false;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    referenceDate = _dateOnly(DateTime.now());
    selectedDate = referenceDate;

    // 위젯에서 전달받은 자녀/부모 정보 설정
    _isChild = widget.isChild ?? false;
    _selectedParentId = widget.selectedParentId;

    _exercisePageController = PageController(
      initialPage: _pageFromDate(selectedDate),
    );
    _dateCarouselController = PageController(
      initialPage: _pageFromDate(selectedDate),
    );

    _loadPersistedExerciseTimes();
    _loadExerciseFromServer(selectedDate); // 초기 날짜의 서버 데이터 조회
  }

  Future<void> _loadPersistedExerciseTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_exerciseTimesKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final Map<String, Map<String, int>> loaded = {};
          decoded.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              final hours = value['hours'] is int
                  ? value['hours'] as int
                  : int.tryParse(value['hours'].toString()) ?? 0;
              final minutes = value['minutes'] is int
                  ? value['minutes'] as int
                  : int.tryParse(value['minutes'].toString()) ?? 0;
              loaded[key] = {'hours': hours, 'minutes': minutes};
            }
          });
          setState(() {
            exerciseTimes = loaded;
          });
        }
      }
    } catch (_) {
      // ignore corrupted prefs
    }
  }

  Future<void> _persistExerciseTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(exerciseTimes);
      await prefs.setString(_exerciseTimesKey, encoded);
    } catch (_) {
      // ignore persistence failure
    }
  }

  // 서버에서 운동 기록 조회
  Future<bool> _loadExerciseFromServer(DateTime date) async {
    try {
      final dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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

        // grid에서 총 운동 시간 계산
        int totalCells = 0;
        for (var row in serverGrid) {
          for (var cell in row) {
            if (cell == 1) totalCells++;
          }
        }

        final totalMinutes = totalCells * 10;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;

        // exerciseTimes 맵에 저장
        setState(() {
          exerciseTimes[dateKey] = {'hours': hours, 'minutes': minutes};
        });

        // SharedPreferences에도 저장
        _persistExerciseTimes();

        return true;
      } else {
        // 서버에 데이터가 없으면 로컬에서도 삭제
        setState(() {
          exerciseTimes.remove(dateKey);
        });
        _persistExerciseTimes();
        return false;
      }
    } catch (e) {
      print('서버에서 운동 기록 조회 실패: $e');
      return false;
    }
  }

  // Normalize to date-only (midnight)
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // Convert date to page index
  int _pageFromDate(DateTime date) {
    final normalized = _dateOnly(date);
    final diff = normalized.difference(referenceDate).inDays;
    return _centerPage + diff;
  }

  // Convert page index to date
  DateTime _dateFromPage(int page) {
    final offset = page - _centerPage;
    return referenceDate.add(Duration(days: offset));
  }

  // Get exercise time for a date safely
  Map<String, int> getExerciseTime(DateTime date) {
    final key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return exerciseTimes[key] ?? {'hours': 0, 'minutes': 0};
  }

  // Save locally and persist
  void saveExerciseTime(DateTime date, int hours, int minutes) {
    final key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    setState(() {
      exerciseTimes[key] = {'hours': hours, 'minutes': minutes};
    });
    _persistExerciseTimes();
  }

  void _updateFromButton(DateTime date) {
    final normalizedDate = _dateOnly(date);
    final targetPage = _pageFromDate(normalizedDate);

    setState(() {
      selectedDate = normalizedDate;
      _triggerSource = _TriggerSource.button;
    });

    _loadExerciseFromServer(normalizedDate);

    if (_exercisePageController.hasClients) {
      _exercisePageController
          .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          )
          .then((_) {
            setState(() {
              _triggerSource = _TriggerSource.none;
            });
          });
    } else {
      setState(() {
        _triggerSource = _TriggerSource.none;
      });
    }

    if (_dateCarouselController.hasClients) {
      _dateCarouselController.jumpToPage(targetPage);
    }
  }

  void _updateFromSwipe(int index) {
    final newDate = _dateFromPage(index);
    final normalizedDate = _dateOnly(newDate);
    final targetPage = _pageFromDate(normalizedDate);

    setState(() {
      selectedDate = normalizedDate;
      _triggerSource = _TriggerSource.swipe;
    });

    if (_dateCarouselController.hasClients) {
      _dateCarouselController.jumpToPage(targetPage);
    }

    //새로운 날짜의 서버 데이터 조회
    _loadExerciseFromServer(normalizedDate);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _triggerSource = _TriggerSource.none;
        });
      }
    });
  }

  @override
  void dispose() {
    _exercisePageController.dispose();
    _dateCarouselController.dispose();
    super.dispose();
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
            Positioned(
              top: circleSize * 0.45,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 20,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 90),
                              Row(
                                children: [
                                  const Spacer(),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 85,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40,
                                        ),
                                        child: DateCarousel(
                                          initialDate: selectedDate,
                                          controller: _dateCarouselController,
                                          onDateChanged: (date) {
                                            if (_triggerSource ==
                                                _TriggerSource.swipe)
                                              return;
                                            _updateFromButton(date);
                                          },
                                          builder: (context, date) {
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: PageView.builder(
                                            controller: _exercisePageController,
                                            pageSnapping: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            onPageChanged: (index) {
                                              if (_triggerSource ==
                                                  _TriggerSource.button)
                                                return;
                                              _updateFromSwipe(index);
                                            },
                                            itemCount: 10000,
                                            // large buffer for infinite feel
                                            itemBuilder: (context, index) {
                                              final date = _dateFromPage(index);
                                              final exerciseTimeForDate =
                                                  getExerciseTime(date);
                                              final h =
                                                  exerciseTimeForDate['hours'] ??
                                                  0;
                                              final m =
                                                  exerciseTimeForDate['minutes'] ??
                                                  0;

                                              return GestureDetector(
                                                onTap: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ExerciseRecordDetailScreen(
                                                            date: date,
                                                            hours: h,
                                                            minutes: m,
                                                            selectedParentId:
                                                                _selectedParentId,
                                                            isChild: _isChild,
                                                          ),
                                                    ),
                                                  );

                                                  // detail 화면에서 돌아온 후 서버 데이터 다시 조회
                                                  if (result != null &&
                                                      result
                                                          is Map<String, int>) {
                                                    // detail 화면에서 변경된 데이터로 로컬 업데이트
                                                    final hours =
                                                        result['hours'] ?? 0;
                                                    final minutes =
                                                        result['minutes'] ?? 0;
                                                    saveExerciseTime(
                                                      date,
                                                      hours,
                                                      minutes,
                                                    );

                                                    // 서버에서도 최신 데이터 다시 조회 (동기화)
                                                    await _loadExerciseFromServer(
                                                      date,
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 15,
                                                        right: 15,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: const Text(
                                                          '오늘은',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .ongiOrange,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 95,
                                                            height: 95,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    19,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  blurRadius:
                                                                      16,
                                                                  spreadRadius:
                                                                      4,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  h
                                                                      .toString()
                                                                      .padLeft(
                                                                        2,
                                                                        '0',
                                                                      ),
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        60,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 9,
                                                          ),
                                                          const Text(
                                                            '시간',
                                                            style: TextStyle(
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 13,
                                                          ),
                                                          Container(
                                                            width: 95,
                                                            height: 95,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    19,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  blurRadius:
                                                                      16,
                                                                  spreadRadius:
                                                                      4,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        4,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  m
                                                                      .toString()
                                                                      .padLeft(
                                                                        2,
                                                                        '0',
                                                                      ),
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        60,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 9,
                                                          ),
                                                          const Text(
                                                            '분',
                                                            style: TextStyle(
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      const Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          '운동했어요!',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .ongiOrange,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Circle with logo on top of white background
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
                        padding: EdgeInsets.only(top: circleSize),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                '오늘 목표 운동 시간,',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              Text(
                                _isChild ? '다 채우셨을까요?' : '다 채우셨나요?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Image.asset(
                                  'assets/images/exercise_record_title_logo.png',
                                  width: circleSize * 0.3,
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
          ],
        ),
      ),
    );
  }
}
