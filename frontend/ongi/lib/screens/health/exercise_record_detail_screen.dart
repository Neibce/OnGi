import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/widgets/time_grid.dart';
import 'package:ongi/services/exercise_service.dart';

class ExerciseRecordDetailScreen extends StatefulWidget {
  final DateTime date;
  final int hours;
  final int minutes;
  final String? selectedParentId;
  final bool? isChild;

  const ExerciseRecordDetailScreen({
    super.key,
    required this.date,
    required this.hours,
    required this.minutes,
    this.selectedParentId,
    this.isChild,
  });

  @override
  State<ExerciseRecordDetailScreen> createState() =>
      _ExerciseRecordDetailScreenState();
}

class _ExerciseRecordDetailScreenState
    extends State<ExerciseRecordDetailScreen> {
  List<int> selected = [];
  Map<String, String> _lastSentDurationPerDate = {}; // 날짜별 마지막 전송 기록 (중복 방지용)

  static const int _centerPage = 5000;
  late final DateTime referenceDate;
  DateTime selectedDate = DateTime.now();
  late final PageController _dateCarouselController;
  
  // 자녀용 상태 관리
  bool _isChild = false;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    referenceDate = _dateOnly(DateTime.now());
    selectedDate = _dateOnly(widget.date);
    
    // 위젯에서 전달받은 자녀/부모 정보 설정
    _isChild = widget.isChild ?? false;
    _selectedParentId = widget.selectedParentId;

    _dateCarouselController = PageController(
      initialPage: _pageFromDate(selectedDate),
    );

    _loadExerciseFromServer(selectedDate);
  }

  @override
  void dispose() {
    _dateCarouselController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int _pageFromDate(DateTime date) {
    final normalized = _dateOnly(date);
    final diff = normalized.difference(referenceDate).inDays;
    return _centerPage + diff;
  }

  // DateTime _dateFromPage(int page) {
  //   final offset = page - _centerPage;
  //   return referenceDate.add(Duration(days: offset));
  // }

  void _updateFromDateCarousel(DateTime date) async {
    final normalizedDate = _dateOnly(date);
    setState(() {
      selectedDate = normalizedDate;
    });

    await _loadExerciseFromServer(normalizedDate);
  }

  String _calExTime(List<int> selectedCells) {
    final totalMinutes = selectedCells.length * 10;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String result = '';
    if (hours > 0) {
      result += '$hours시간';
      if (minutes > 0) {
        result += ' $minutes분';
      }
    } else if (minutes > 0) {
      result += '$minutes분';
    } else {
      result = '0분';
    }

    return result;
  }

  List<List<int>> _convertToGrid(List<int> selectedCells) {
    List<List<int>> grid = List.generate(24, (i) => List.filled(6, 0));

    for (int index in selectedCells) {
      if (index >= 0 && index < 144) {
        int hour = index ~/ 6;
        int tenMinute = index % 6;
        grid[hour][tenMinute] = 1;
      }
    }

    return grid;
  }

  List<int> _convertFromGrid(List<List<int>> grid) {
    List<int> selectedCells = [];

    for (int hour = 0; hour < 24; hour++) {
      if (hour < grid.length) {
        for (int tenMinute = 0; tenMinute < 6; tenMinute++) {
          if (tenMinute < grid[hour].length && grid[hour][tenMinute] == 1) {
            int index = hour * 6 + tenMinute;
            selectedCells.add(index);
          }
        }
      }
    }

    return selectedCells;
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

        final selectedCells = _convertFromGrid(serverGrid);

        final normalizedDate = _dateOnly(date);
        final normalizedSelectedDate = _dateOnly(selectedDate);
        if (normalizedDate.isAtSameMomentAs(normalizedSelectedDate)) {
          setState(() {
            selected = selectedCells;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }

        return true;
      }

      final normalizedDate = _dateOnly(date);
      final normalizedSelectedDate = _dateOnly(selectedDate);
      if (normalizedDate.isAtSameMomentAs(normalizedSelectedDate)) {
        setState(() {
          selected = [];
        });
      }

      return false;
    } catch (e) {
      print('서버에서 운동 기록 조회 실패: $e');

      final normalizedDate = _dateOnly(date);
      final normalizedSelectedDate = _dateOnly(selectedDate);
      if (normalizedDate.isAtSameMomentAs(normalizedSelectedDate)) {
        setState(() {
          selected = [];
        });
      }

      return false;
    }
  }

  Future<void> _autoSendToServer(List<int> selectedCells) async {
    final dateKey =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    final grid = _convertToGrid(selectedCells);
    final gridHash = selectedCells.toString();

    if (_lastSentDurationPerDate[dateKey] == gridHash) return;

    try {
      final exerciseService = ExerciseService();
      await exerciseService.exerciseRecord(date: dateKey, grid: grid);

      _lastSentDurationPerDate[dateKey] = gridHash;

      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '운동 기록 전송 실패: $e',
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
      }
    }
  }

  Map<String, int> _calculateHoursAndMinutes(List<int> selectedCells) {
    final totalMinutes = selectedCells.length * 10;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return {'hours': hours, 'minutes': minutes};
  }

  void _handleBack() async {
    final timeData = _calculateHoursAndMinutes(selected);

    await _autoSendToServer(selected);

    if (mounted) {
      Navigator.pop(context, timeData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.ongiLigntgrey,
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -circleSize * 0.81),
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
                          padding: EdgeInsets.only(top: circleSize * 0.62),
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
                                const Text(
                                  '다 채우셨나요?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
                top: circleSize * 0.45,
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          right: 0,
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: DateCarousel(
                              initialDate: selectedDate,
                              controller: _dateCarouselController,
                              onDateChanged: (date) {
                                _updateFromDateCarousel(date);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 25, top: 75),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '오늘은',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.ongiOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '${_calExTime(selected)} ',
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: AppColors.ongiOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '운동했어요!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.ongiOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 155,
                          left: 7,
                          right: 7,
                          bottom: 20,
                          child: Center(
                            child: TimeGrid(
                              key: ValueKey(
                                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}-${selected.length}-${selected.hashCode}",
                              ),
                              initialSelected: selected,
                              cellColor: Colors.white,
                              cellSelectedColor: AppColors.ongiOrange,
                              borderColor: AppColors.ongiOrange,
                              onValueChanged: _isChild ? null : (newList) {
                                setState(() => selected = newList);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: circleSize * 0.18,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Image.asset(
                      'assets/images/exercise_record_title_logo.png',
                      width: circleSize * 0.23,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _handleBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
