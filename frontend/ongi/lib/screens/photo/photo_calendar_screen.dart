import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/services/photo_calendar_service.dart';
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
  final PhotoCalendarService _service = PhotoCalendarService();
  Map<String, int> _writtenCounts = <String, int>{};
  Set<String> _loggedDayKeys = <String>{};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    _fetchCalendarDataForMonth(_focusedDay);
  }

  void _goBackToCalendar() => setState(() => _currentView = 'calendar');

  Widget _dayCellBuilder(
    BuildContext context,
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final int writtenCount = _writtenCounts[_formatDateKey(day)] ?? 0;
    final List<Color> circleColors = _buildCircleColorsForCount(writtenCount);

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
          const SizedBox(height: 130),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
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
                    _fetchCalendarDataForMonth(selectedDay);
                  } else {
                    _selectedDate = selectedDay;
                    _focusedDay = selectedDay;
                    _currentView = 'photoDate';
                  }
                });
              },
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDate, day) &&
                  !isSameDay(day, DateTime.now()),
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                _fetchCalendarDataForMonth(focusedDay);
              },
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
          PhotoDateScreen(date: _selectedDate != null ? _formatDateKey(_selectedDate!) : _formatDateKey(DateTime.now())),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 40,
            child: GestureDetector(
              onTap: _goBackToCalendar,
              child: SizedBox(
                width: 36,
                height: 36,
                child: SvgPicture.asset('assets/images/back_icon_black.svg'),
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
      body: AppLightBackground(
        child: Stack(
          children: [
            _buildCurrentView(),
            if (_isLoading && _currentView == 'calendar')
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.ongiOrange,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatYearMonth(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  String _formatDateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  List<Color> _buildCircleColorsForCount(int count) {
    // final Color orange = AppColors.ongiOrange.withValues(alpha: 0.9);
    final Color orange = AppColors.ongiOrange;
    final Color grey = AppColors.ongiGrey;

    if (count >= 4) {
      return [orange, orange, orange, orange];
    }
    final List<Color> colors = [grey, grey, grey, grey];
    for (int i = 0; i < count && i < 4; i++) {
      colors[i] = orange;
    }
    return colors;
  }

  Future<void> _fetchCalendarDataForMonth(DateTime dateInMonth) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String ym = _formatYearMonth(dateInMonth);
      final Map<String, dynamic> response = await _service.getPhotoCalendar(
        yearmonth: ym,
      );

      final Object? countsObj = response['writtenMemberCount'];
      final Map<String, dynamic> countsMap = countsObj is Map<String, dynamic>
          ? countsObj
          : <String, dynamic>{};

      final Map<String, int> normalizedCounts = <String, int>{};
      for (final entry in countsMap.entries) {
        if (!entry.key.startsWith('$ym-')) continue;
        final dynamic v = entry.value;
        int count;
        if (v is num) {
          count = v.toInt();
        } else if (v is String) {
          count = int.tryParse(v) ?? 0;
        } else {
          count = 0;
        }
        normalizedCounts[entry.key] = count;
      }

      final Set<String> days = normalizedCounts.entries
          .where((e) => e.value > 0)
          .map((e) => e.key)
          .toSet();

      setState(() {
        _writtenCounts = normalizedCounts;
        _loggedDayKeys = days;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '캘린더 데이터를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';
        _loggedDayKeys = <String>{};
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
