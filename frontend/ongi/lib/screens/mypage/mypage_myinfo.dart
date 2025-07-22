import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/utils/prefs_manager.dart';

class Myinfo extends StatelessWidget {
  const Myinfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        final familycode = userInfo['familycode'] ?? '1234567890';
        final familyName = userInfo['familyName'] ?? '우리가좍';
        final profileImage = userInfo['profileImage'] ?? 'assets/images/users/elderly_woman.png';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              ClipOval(
                child: Image.asset(
                  profileImage,
                  width: 112,
                  height: 160,
                ),
              ),
              const SizedBox(width: 4),
              // 오른쪽 정보들
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name님',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    // 나머지 정보에만 오른쪽 여백
                    Padding(
                      padding: const EdgeInsets.only(left: 8), // 원하는 만큼 조절
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$familyName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$familycode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                          const SizedBox(height: 4),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.ongiOrange, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                            ),
                            child: const Text(
                              '프로필 수정',
                              style: TextStyle(
                                color: AppColors.ongiOrange,
                                fontWeight: FontWeight.w700,
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