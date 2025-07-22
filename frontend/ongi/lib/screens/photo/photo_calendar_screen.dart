import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/photo/photo_date_screen.dart';
import 'package:ongi/widgets/day_circles.dart';

class PhotoCalendarScreen extends StatefulWidget {
  const PhotoCalendarScreen({super.key});

  @override
  State<PhotoCalendarScreen> createState() => _PhotoCalendarScreenState();
}

class _PhotoCalendarScreenState extends State<PhotoCalendarScreen> {
  String _currentView = 'calendar';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
  }

  void _goBackToCalendar() => setState(() => _currentView = 'calendar');

  Widget _dayCellBuilder(
    BuildContext context,
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    const circleColors = [
      AppColors.ongiOrange,
      AppColors.ongiOrange,
      AppColors.ongiOrange,
      AppColors.ongiGrey,
    ];

    final decoration = isToday
        ? const BoxDecoration(
            color: AppColors.ongiOrange,
            shape: BoxShape.circle,
          )
        : isSelected
        ? BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ongiOrange),
          )
        : const BoxDecoration(shape: BoxShape.circle);

    final textStyle = isToday
        ? const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )
        : isSelected
        ? const TextStyle(
            color: AppColors.ongiOrange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )
        : const TextStyle(fontSize: 16);

    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: decoration,
                child: Text('${day.day}', style: textStyle),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: DayCircles(
                appColors: circleColors,
                padding: const EdgeInsets.only(left: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outsideDayCellBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(width: 16 * 2 + 7 * 2, height: 16 * 2 + 7 * 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 150),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '우리가족의',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                ),
                Text(
                  '마음 기록',
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
          Container(
            margin: const EdgeInsets.fromLTRB(15, 50, 15, 0),
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 1, 1),
              focusedDay: _focusedDay,
              rowHeight: 90,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                headerPadding: EdgeInsets.only(bottom: 30),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: AppColors.ongiOrange,
                  fontWeight: FontWeight.w700,
                ),
                weekendStyle: TextStyle(
                  color: AppColors.ongiOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  bool isOutsideDay = selectedDay.month != _focusedDay.month;

                  if (isOutsideDay) {
                    _focusedDay = selectedDay;
                    _selectedDate = null;
                  } else {
                    _selectedDate = selectedDay;
                    _focusedDay = selectedDay;
                  }
                });
              },
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDate, day) &&
                  !isSameDay(day, DateTime.now()),
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.ongiOrange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(shape: BoxShape.circle),
                todayTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: TextStyle(
                  color: AppColors.ongiOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, _) => _dayCellBuilder(ctx, day),
                selectedBuilder: (ctx, day, _) =>
                    _dayCellBuilder(ctx, day, isSelected: true),
                todayBuilder: (ctx, day, _) =>
                    _dayCellBuilder(ctx, day, isToday: true),
                outsideBuilder: _outsideDayCellBuilder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_currentView == 'photoDate') {
      return Stack(
        children: [
          const PhotoDateScreen(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: GestureDetector(
              onTap: _goBackToCalendar,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return _buildCalendarView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(child: _buildCurrentView()),
    );
  }
}
