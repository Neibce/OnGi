import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/widgets/time_grid.dart';

class ExerciseRecordDetailScreen extends StatefulWidget {
  final DateTime date;
  final int hours;
  final int minutes;

  const ExerciseRecordDetailScreen({
    super.key,
    required this.date,
    required this.hours,
    required this.minutes,
  });

  @override
  State<ExerciseRecordDetailScreen> createState() =>
      _ExerciseRecordDetailScreenState();
}

class _ExerciseRecordDetailScreenState
    extends State<ExerciseRecordDetailScreen> {
  List<int> selected = [];

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

  // Calculate hours and minutes from selected cells
  Map<String, int> _calculateHoursAndMinutes(List<int> selectedCells) {
    final totalMinutes = selectedCells.length * 10;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return {'hours': hours, 'minutes': minutes};
  }

  // Handle back navigation with exercise time data
  void _handleBack() {
    final timeData = _calculateHoursAndMinutes(selected);
    Navigator.pop(context, timeData);
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
                top: circleSize * 0.5,
                left: 0,
                right: 0,
                bottom: 0,
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
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          right: 0,
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: DateCarousel(
                              initialDate: widget.date,
                              onDateChanged: (selectedDate) {},
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
                          top: 160,
                          left: 7,
                          right: 7,
                          bottom: 20,
                          child: Center(
                            child: TimeGrid(
                              initialSelected: selected,
                              cellColor: Colors.white,
                              cellSelectedColor: AppColors.ongiOrange,
                              borderColor: AppColors.ongiOrange,
                              onValueChanged: (newList) {
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
                top: circleSize * 0.23,
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
