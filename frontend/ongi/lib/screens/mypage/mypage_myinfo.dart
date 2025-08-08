import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Myinfo extends StatelessWidget {
  const Myinfo({Key? key}) : super(key: key);

  Future<Map<String, String>> fetchFamilyInfo() async {
    final token = await PrefsManager.getAccessToken();
    if (token == null) throw Exception('로그인 필요');
    final url = Uri.parse('https://ongi-1049536928483.asia-northeast3.run.app/family');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'familycode': data['code'] ?? '',
        'familyname': data['name'] ?? '',
      };
    } else {
      throw Exception('가족 정보 불러오기 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<Map<String, String>>(
      future: fetchFamilyInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        final familycode = snapshot.data?['familycode'] ?? '가족코드';
        final familyName = snapshot.data?['familyname'] ?? '가족이름';
        // 기존 PrefsManager.getUserInfo()에서 불러오던 나머지 정보는 그대로 사용
        // (예: name, profileImage, isParent 등)
        // 아래는 예시로 name 등은 PrefsManager에서 계속 불러오도록 유지
        return FutureBuilder<Map<String, String?>> (
          future: PrefsManager.getUserInfo(),
          builder: (context, userSnapshot) {
            final userInfo = userSnapshot.data ?? {};
            final name = userInfo['name'] ?? '사용자';
            final profileImage = userInfo['profileImage'] ?? 'assets/images/users/elderly_woman.png';
            final isParent = userInfo['isParent'] == 'true';
            final roleText = isParent ? '부모' : '자녀';
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
                      height: screenWidth * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.0053),
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
                                horizontal: screenWidth * 0.01,
                                vertical: screenHeight * 0.001,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleText,
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
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.021), // 8/375
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.005), // 4/812
                              Row(
                                children: [
                                  Text(
                                    familyName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.011), // 4/375
                                  Text(
                                    familycode,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.021), // 8/375
                                  Builder(
                                    builder: (context) => OutlinedButton(
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: familycode));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('가족코드가 복사되었습니다.')),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.ongiOrange, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.01,
                                          vertical: screenHeight * 0.001,
                                        ),
                                      ),
                                      child: Text(
                                        '가족코드 공유',
                                        style: TextStyle(
                                          color: AppColors.ongiOrange,
                                          fontSize: screenWidth * 0.019,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Pretendard',
                                        ),
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
      },
    );
  }
}