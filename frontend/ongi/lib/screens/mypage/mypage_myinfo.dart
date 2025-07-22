import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/utils/prefs_manager.dart';

class Myinfo extends StatelessWidget {
  const Myinfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<Map<String, String?>> (
      future: PrefsManager.getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러: \\${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        final userInfo = snapshot.data ?? {};
        final name = userInfo['name'] ?? '사용자님';
        final familycode = userInfo['familycode'] ?? '33HYF6';
        final familyName = userInfo['familyName'] ?? '우리가족이얌';
        final profileImage = userInfo['profileImage'] ?? 'assets/images/users/elderly_woman.png';

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 32/375
            vertical: screenHeight * 0.02,   // 16/812
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              ClipOval(
                child: Image.asset(
                  profileImage,
                  width: screenWidth * 0.3, // 112/375
                  height: screenWidth * 0.4, // 160/375
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: screenWidth * 0.0053), // 2/375
              // 오른쪽 정보들
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$name님',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.064, // 24/375
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.025, // 4/375
                            vertical: screenHeight * 0.001, // 1/812
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '부모 1',
                            style: TextStyle(
                              color: AppColors.ongiOrange,
                              fontSize: screenWidth * 0.019,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 오른쪽 여백
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.021), // 8/375
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.005), // 4/812
                          Row(
                            children: [
                              Text(
                                '$familyName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.011), // 4/375
                              Text(
                                '$familycode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.021), // 8/375
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.011, // 4/375
                                  vertical: screenHeight * 0.0012, // 1/812
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '가족코드공유',
                                  style: TextStyle(
                                    color: AppColors.ongiOrange,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02), // 4/812
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.ongiOrange, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.027, // 10/375
                                vertical: screenHeight * 0.002, // 1/812
                              ),
                            ),
                            child: const Text(
                              '프로필 수정',
                              style: TextStyle(
                                color: AppColors.ongiOrange,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}