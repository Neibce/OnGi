import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/date_carousel.dart';
import 'exercise_record_detail_screen.dart';

class ExerciseRecordScreen extends StatefulWidget {
  const ExerciseRecordScreen({super.key});

  @override
  State<ExerciseRecordScreen> createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends State<ExerciseRecordScreen> {
  DateTime selectedDate = DateTime.now();
  late PageController _exercisePageController;
  int _currentExercisePage = 5000; // Start from middle for infinite scroll
  late PageController _dateCarouselController;
  bool _isButtonTriggered = false; // Prevent exercise onPageChanged when triggered by button
  bool _isSwipeTriggered = false;  // Prevent button callback when triggered by swipe
  
  // Get exercise time for a specific date (placeholder: returns 0)
  Map<String, int> getExerciseTime(DateTime date) {
    // TODO: Replace with real backend call
    return {'hours': 1, 'minutes': 30};
  }

  // Convert page index to date for exercise PageView
  DateTime _dateFromExercisePage(int page) {
    final offset = page - 5000;
    return DateTime.now().add(Duration(days: offset));
  }

  @override
  void initState() {
    super.initState();
    _exercisePageController = PageController(initialPage: _currentExercisePage);
    _dateCarouselController = PageController(initialPage: 5000);
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
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Content inside white container
                    Builder(
                      builder: (context) {
                        final exerciseTime = getExerciseTime(selectedDate);
                        
                        return Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 140),
                              Row(
                                children: [
                                  Spacer(),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 40),
                                        child: DateCarousel(
                                          initialDate: selectedDate,
                                          controller: _dateCarouselController,
                                          onDateChanged: (date) {
                                            if (_isSwipeTriggered) return; // Ignore if triggered by swipe
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
                                  child: Column(
                                    children: [
                                      // Exercise time section
                                      SizedBox(
                                        height: 200,
                                        child: PageView.builder(
                                          controller: _exercisePageController,
                                          pageSnapping: true,
                                          physics: const ClampingScrollPhysics(),
                                          onPageChanged: (index) {
                                            if (_isButtonTriggered) return; // Ignore if triggered by button
                                            _updateFromSwipe(index);
                                          },
                                          itemCount: 10000,
                                          itemBuilder: (context, index) {
                                            final date = _dateFromExercisePage(index);
                                            final exerciseTimeForDate = getExerciseTime(date);
                                            
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ExerciseRecordDetailScreen(
                                                      date: date,
                                                      hours: exerciseTimeForDate['hours'] ?? 0,
                                                      minutes: exerciseTimeForDate['minutes'] ?? 0,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '오늘은',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.ongiOrange,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    // Exercise time display
                                                    Row(
                                                      children: [
                                                        // Hours container
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.1),
                                                                blurRadius: 16,
                                                                spreadRadius: 4,
                                                                offset: const Offset(0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                exerciseTimeForDate['hours'].toString().padLeft(2, '0'),
                                                                style: const TextStyle(
                                                                  fontSize: 64,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        const Text(
                                                          '시간',
                                                          style: TextStyle(
                                                            fontSize: 32,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 24),
                                                        // Minutes container
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.1),
                                                                blurRadius: 16,
                                                                spreadRadius: 4,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                exerciseTimeForDate['minutes'].toString().padLeft(2, '0'),
                                                                style: const TextStyle(
                                                                  fontSize: 64,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        const Text(
                                                          '분',
                                                          style: TextStyle(
                                                            fontSize: 32,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    // "운동했어요!" text
                                                    const Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                        '운동했어요!',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.ongiOrange,
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
                            ],
                          )
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
                              const Text(
                                '다 채우셨나요?',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
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

  // When button is clicked -> animate exercise area
  void _updateFromButton(DateTime date) {
    _isButtonTriggered = true;
    
    final daysDiff = date.difference(DateTime.now()).inDays;
    final targetPage = 5000 + daysDiff;
    
    setState(() {
      selectedDate = date;
      _currentExercisePage = targetPage;
    });
    
    // Animate exercise PageView
    if (_exercisePageController.hasClients) {
      _exercisePageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      ).then((_) {
        _isButtonTriggered = false;
      });
    } else {
      _isButtonTriggered = false;
    }
  }

  // When exercise area is swiped -> update date carousel
  void _updateFromSwipe(int index) {
    _isSwipeTriggered = true;
    
    final newDate = _dateFromExercisePage(index);
    final daysDiff = newDate.difference(DateTime.now()).inDays;
    final targetPage = 5000 + daysDiff;
    
    setState(() {
      _currentExercisePage = index;
      selectedDate = newDate;
    });
    
    // Update DateCarousel (no animation needed, just sync the display)
    if (_dateCarouselController.hasClients) {
      _dateCarouselController.jumpToPage(targetPage);
    }
    
    // Reset flag after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _isSwipeTriggered = false;
    });
  }
}
