import 'package:flutter/material.dart';
import 'package:ongi/screens/home_screen.dart';
import 'package:ongi/screens/health_log_screen.dart';
import 'package:ongi/screens/family_tempbar_screen.dart';
import 'package:ongi/screens/home_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthLogScreen(),
    const AddRecordScreen(),
    const FamilyTempbarScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      height: 120,
      decoration: const BoxDecoration(color: Colors.white),
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
                  : Colors.grey[300],
            ),
          ),
          _buildNavItem(
            1,
            SvgPicture.asset(
              'assets/images/nav_Heart.svg',
              color: _currentIndex == 1
                  ? AppColors.ongiOrange
                  : Colors.grey[300],
              width: 24,
              height: 24,
            ),
          ),
          GestureDetector(
            onTap: () => _onTabTapped(2),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.ongiOrange,
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
            3,
            SvgPicture.asset(
              'assets/images/nav_Commun.svg',
              color: _currentIndex == 3
                  ? AppColors.ongiOrange
                  : Colors.grey[300],
              width: 24,
              height: 24,
            ),
          ),
          _buildNavItem(
            4,
            SvgPicture.asset(
              'assets/images/nav_Mypage.svg',
              color: _currentIndex == 4
                  ? AppColors.ongiOrange
                  : Colors.grey[300],
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, Widget iconWidget) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }
}

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '기록 추가',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 80, color: AppColors.ongiOrange),
            SizedBox(height: 16),
            Text(
              '새 기록 추가',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '건강 상태를 기록해보세요',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '프로필 화면',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '사용자 정보 및 설정',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
