import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/add_record_screen.dart';
import 'package:ongi/screens/home/home_screen.dart';
import 'package:ongi/screens/health/health_home_screen.dart';
import 'package:ongi/screens/photo/photo_calendar_screen.dart';
import 'package:ongi/screens/mypage/mypage_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/maum_log_service.dart';
import 'package:intl/intl.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex;
  const BottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthHomeScreen(),
    const PhotoCalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _onAddRecordTapped() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final maumLogResponse = await MaumLogService.getMaumLog(today);

      if (maumLogResponse.hasUploadedOwn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 마음 기록 완료!',
                    style: TextStyle(
                      color: AppColors.ongiOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '같은 날에는 한 번만 기록할 수 있어요.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45,
                    ),
                  ),
                ],
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
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
        }
      }
    } catch (e) {
      print('마음로그 확인 중 에러: $e');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddRecordScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            SvgPicture.asset(
              'assets/images/nav_Home.svg',
              width: 24,
              height: 24,
              color: _currentIndex == 0
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
            ),
            '홈',
          ),
          _buildNavItem(
            1,
            SvgPicture.asset(
              'assets/images/nav_Health.svg',
              color: _currentIndex == 1
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 32,
              height: 32,
            ),
            '건강 기록',
          ),
          GestureDetector(
            onTap: () => _onAddRecordTapped(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.ongiBlue, AppColors.ongiOrange],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 36),
            ),
          ),
          _buildNavItem(
            2,
            SvgPicture.asset(
              'assets/images/nav_Commun.svg',
              color: _currentIndex == 2
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 24,
              height: 24,
            ),
            '앨범',
          ),
          _buildNavItem(
            3,
            SvgPicture.asset(
              'assets/images/nav_Mypage.svg',
              color: _currentIndex == 3
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 24,
              height: 24,
            ),
            '마이페이지',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, Widget iconWidget, String text) {
    final isSelected = index == _currentIndex;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.ongiOrange : Colors.grey[300],
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
