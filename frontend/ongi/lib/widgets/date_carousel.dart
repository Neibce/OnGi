import 'package:flutter/material.dart';

class DateCarousel extends StatefulWidget {
  final DateTime initialDate; // defaults to DateTime.now()
  final Widget Function(BuildContext context, DateTime date)? builder;
  final void Function(DateTime date)? onDateChanged;
  final PageController? controller;

  DateCarousel({
    super.key,
    DateTime? initialDate,
    this.builder,
    this.onDateChanged,
    this.controller,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  State<DateCarousel> createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  // Start in the middle of a large range to allow "infinite" swiping.
  static const int _kInitialPage = 5000;
  late final PageController _controller;

  // Current page index.
  int _currentIndex = _kInitialPage;
  bool _isUpdating = false;
  int? _lastUpdateTime;
  static const int _debounceMs = 100; // Reduced to 100ms for better responsiveness

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PageController(initialPage: _kInitialPage);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  // Convert page index -> date.
  DateTime _dateFromIndex(int index) {
    final int offset = index - _kInitialPage;
    return widget.initialDate.add(Duration(days: offset));
  }

  // Korean weekday string.
  String _weekdayKor(DateTime date) {
    const weekdays = [
      '월요일',
      '화요일',
      '수요일',
      '목요일',
      '금요일',
      '토요일',
      '일요일',
    ];
    return weekdays[date.weekday - 1];
  }

  // Format: 2025년 6월 13일
  String _formatDate(DateTime date) =>
      '${date.year}년 ${date.month}월 ${date.day}일';

  void _goToPage(int page) {
    if (_isUpdating || page == _currentIndex) return;
    if (!_controller.hasClients) return; // attach 안됐으면 무시
    _isUpdating = true;
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          _isUpdating = false;
        });
      });
    }

  void _goPrevious() {
    _goToPage(_currentIndex - 1);
  }

  void _goNext() {
    _goToPage(_currentIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDate = _dateFromIndex(_currentIndex);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _goPrevious,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(currentDate),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    _weekdayKor(currentDate),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _goNext,
            ),
          ],
        ),
        SizedBox(
          height: 20,
          child: PageView.builder(
            controller: _controller,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              print('[DateCarousel] onPageChanged: $index');
              setState(() {
                _currentIndex = index;
              });
              if (widget.onDateChanged != null) {
                widget.onDateChanged!(_dateFromIndex(index));
              }
            },
            itemCount: 10000,
            itemBuilder: (context, index) {
              final date = _dateFromIndex(index);
              return Center(
                child: Text(
                  '${date.year}-${date.month}-${date.day}',
                  style: const TextStyle(color: Colors.transparent),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 