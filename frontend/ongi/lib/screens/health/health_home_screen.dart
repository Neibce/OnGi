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

class HealthHomeScreen extends StatefulWidget {
  const HealthHomeScreen({super.key});

  @override
  State<HealthHomeScreen> createState() => _HealthHomeScreenState();
}

class _HealthHomeScreenState extends State<HealthHomeScreen> {
  String username = '사용자';
  String _currentView = 'home'; // 'home', 'pain', 'pills', 'exercise', 'steps'
  int _todayExerciseHours = 0;
  int _todayExerciseMinutes = 0;
  bool _isLoadingExercise = true;
  int _todaySteps = 0;
  int _todayPillCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTodayExerciseTime();
    _loadStep();
    _loadPillCount();
  }

  Future<void> _loadUserName() async {
    String? savedUsername = await PrefsManager.getUserName();
    if (savedUsername != null) {
      setState(() {
        username = savedUsername;
      });
    }
  }

  Future<void> _loadTodayExerciseTime() async {
    try {
      final now = DateTime.now();
      final dateKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final exerciseService = ExerciseService();

      final serverData = await exerciseService.getExerciseRecord(date: dateKey);

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
      final now = DateTime.now();
      final dateKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final stepService = StepService();

      final serverData = await stepService.getSteps(date: dateKey);

      int todaySteps = 0;
      if (serverData != null) {
        final dynamic stepsField =
            serverData['totalSteps'] ??
            serverData['steps'] ??
            serverData['total'];
        if (stepsField is int) {
          todaySteps = stepsField;
        } else if (stepsField != null) {
          todaySteps = int.tryParse(stepsField.toString()) ?? 0;
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
      int todayPillCount = (await PillService.getTodayPillSchedule()).length;
      _todayPillCount = todayPillCount;
    } catch (e) {
      print('오늘 걸음 수 조회 실패: $e');
      setState(() {
        _todayPillCount = 0;
      });
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

  void _goBackToHome() {
    bool wasExerciseView = _currentView == 'exercise';

    setState(() {
      _currentView = 'home';
    });

    if (wasExerciseView) {
      _refreshExerciseTime();
    }
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
      default:
        return _buildHomeView();
    }
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 30,
      child: GestureDetector(
        onTap: _goBackToHome,
        // child: Container(
        //   width: 44,
        //   height: 44,
        //   child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
        // ),
        child: SvgPicture.asset('assets/images/back_icon_white.svg'),
      ),
    );
  }

  Widget _buildPainInputView() {
    return Stack(
      children: [const HealthStatusInputScreen(), _buildBackButton()],
    );
  }

  Widget _buildPillHistoryView() {
    return Stack(children: [const PillHistoryScreen(), _buildBackButton()]);
  }

  Widget _buildExerciseView() {
    return Stack(children: [const ExerciseRecordScreen(), _buildBackButton()]);
  }

  Widget _buildStepTrackerView() {
    return Stack(
      children: [const FamilyStepTrackerScreen(), _buildBackButton()],
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
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
                Text(
                  '$username님의',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
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
                            ),
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
                              children: [
                                const TextSpan(
                                  text: '오늘 ',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$_todayPillCount개의 약',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: AppColors.ongiOrange,
                                  ),
                                ),
                                const TextSpan(
                                  text: '을\n더 섭취하셔야 해요!',
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
                    onPressed: () => _changeView('steps'),
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
                                  text: '$_todaySteps',
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
                          bottom: 10,
                          child: SvgPicture.asset(
                            'assets/images/walk_icon.svg',
                            width: 150,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(child: _buildCurrentView()),
    );
  }
}
