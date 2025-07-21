import 'package:flutter/material.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/user_service.dart';
import 'package:ongi/screens/mypage/mypage_myinfo.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  String? _username;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userInfo = await UserService().user();
      setState(() {
        _username = userInfo['username'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await PrefsManager.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const StartScreen()),
        (route) => false,
      );
    }
  }

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
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

