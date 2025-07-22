import 'package:flutter/material.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/mypage/mypage_myinfo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget buildMenuList(BuildContext context) {
    const menuItems = [
      '개인정보 보호',
      '시스템 알림',
      '공지사항',
      '정보',
      '문의하기',
      '로그아웃',
    ];

    final double gap = MediaQuery.of(context).size.height * 0.02;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in menuItems) ...[
            SizedBox(height: gap),
            Text(item, style: const TextStyle(fontSize: 24)),
          ]
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

