import 'package:flutter/material.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/mypage/mypage_myinfo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget buildMenuList(BuildContext context) {
    final menuItems = ['개인정보 보호', '시스템 알림', '공지사항', '정보', '문의하기', '로그아웃'];

    final double gap = MediaQuery.of(context).size.height * 0.02;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(left: 0, right: screenWidth * 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in menuItems) ...[
            SizedBox(height: gap),
            item == '로그아웃'
                ? GestureDetector(
                    onTap: () async {
                      await PrefsManager.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '로그아웃되었습니다.',
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
                      await Future.delayed(const Duration(milliseconds: 500));
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  )
                : Text(item, style: const TextStyle(fontSize: 24)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ongiOrange,
      appBar: AppBar(backgroundColor: AppColors.ongiOrange, elevation: 0),
      body: Stack(
        children: [
          Positioned(
            bottom: -MediaQuery.of(context).size.width * 0.6,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.75,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.5,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: AppColors.ongiLigntgrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(260),
                      topRight: Radius.circular(260),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 기존 내용
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  '마이페이지',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Myinfo(),
                ),
                const SizedBox(height: 24),
                buildMenuList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
