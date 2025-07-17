import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/home/home_screen.dart';
import 'package:ongi/screens/health_log_screen.dart';
import 'package:ongi/screens/family_tempbar_screen.dart';
import 'package:ongi/screens/photo_screen.dart';
import 'package:ongi/screens/mypage_screen.dart';
import 'package:ongi/core/app_colors.dart';

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
            onTap: () => _onTabTapped(2),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ AppColors.ongiBlue, AppColors.ongiOrange ],
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
            3,
            SvgPicture.asset(
              'assets/images/nav_Commun.svg',
              color: _currentIndex == 3
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 24,
              height: 24,
            ),
            '앨범',
          ),
          _buildNavItem(
            4,
            SvgPicture.asset(
              'assets/images/nav_Mypage.svg',
              color: _currentIndex == 4
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
                color:isSelected? AppColors.ongiOrange
                    : Colors.grey[300],
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