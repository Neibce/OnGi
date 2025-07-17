import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/services/user_service.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/health/family_step_tracker_screen.dart';
import 'package:ongi/screens/health/pill_history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/health/health_status_input_screen.dart';

class HealthHomeScreen extends StatefulWidget {
  const HealthHomeScreen({super.key});

  @override
  State<HealthHomeScreen> createState() => _HealthHomeScreenState();
}

class _HealthHomeScreenState extends State<HealthHomeScreen> {
  String username = '';
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await _userService.user();
      print('user name: ${userInfo['name']}');

      setState(() {
        username = userInfo['name'] ?? '사용자';
      });
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
      setState(() {
        username = '사용자';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$username님의',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w200,
                        height: 1.2,
                        color: AppColors.ongiOrange,
                      ),
                    ),
                    const Text(
                      '건강 기록',
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
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 260,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.ongiOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HealthStatusInputScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      '어느 곳이',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      '불편하세요?',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 120,
                              child: SvgPicture.asset(
                                'assets/images/ruler_icon.svg',
                                width: 32,
                              ),
                            ),
                            Positioned(
                              left: 165,
                              top: 40,
                              child: Image.asset(
                                'assets/images/sitting_mom_icon.png',
                                width: 200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 130,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          foregroundColor: AppColors.ongiOrange,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HealthStatusInputScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              left: 5,
                              bottom: 10,
                              child: Image.asset(
                                'assets/images/pill_history_title_logo.png',
                                width: 150,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.topRight,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '오늘 ',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '2개의 약', // take_pills 변수 이름 해줘
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: AppColors.ongiOrange,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '을\n더 섭취하셔야 해요!',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 130,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.fromLTRB(20, 14, 10, 0),
                              backgroundColor: AppColors.ongiOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PillHistoryScreen(),
                                ),
                              );
                            },
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '오늘은 ex_time', // exercise_time으로 변수 이름 해조
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '운동하셨네요!',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: -20,
                          child: Image.asset(
                            'assets/images/parent_exercise_icon.png',
                            width: 170,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 130,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          foregroundColor: AppColors.ongiOrange,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FamilyStepTrackerScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              left: 15,
                              bottom: 10,
                              child: Image.asset(
                                'assets/images/step_tracker_title_logo.png',
                                width: 100,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.topRight,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '오늘은 ',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '20,315 ', // walks_count 변수 이름 해줘
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: AppColors.ongiOrange,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '걸음\n걸으셨어요!',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 10,
                              child: SvgPicture.asset(
                                'assets/images/walk_icon.svg',
                                width: 150,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
