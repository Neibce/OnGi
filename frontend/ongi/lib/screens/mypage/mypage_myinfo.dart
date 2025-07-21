import 'package:flutter/material.dart';
import 'package:ongi/services/user_service.dart';
import 'package:ongi/core/app_colors.dart';

class Myinfo extends StatefulWidget {
  const Myinfo({super.key});

  @override
  State<Myinfo> createState() => _MyinfoState();
}

class _MyinfoState extends State<Myinfo> {
  Map<String, dynamic>? userInfo;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await UserService().user();
      setState(() {
        userInfo = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('에러: $error', style: const TextStyle(color: Colors.red)));
    }
    if (userInfo == null) {
      return const Center(child: Text('유저 정보를 불러올 수 없습니다.'));
    }

    final String name = userInfo!['username'] ?? '사용자님';
    final String familyCode = userInfo!['familyCode'] ?? '가족코드';
    final String birth = userInfo!['birth'] ?? '1960년 8월 10일';
    final String phone = userInfo!['phone'] ?? '010-0000-0000';
    final String profileImage = userInfo!['profileImage'] ?? '';

    return Stack(
      children: [
        // 내용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름, 가족코드, 가족코드 공유
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            '가족코드 : $familyCode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '가족코드공유',
                              style: TextStyle(
                                color: AppColors.ongiOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  // 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 부모 태그
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.ongiOrange, width: 1.5),
                          ),
                          child: const Text(
                            '부모 1',
                            style: TextStyle(
                              color: AppColors.ongiOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 6,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          birth,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 프로필 수정 버튼
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.ongiOrange, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
            ],
          ),
        ),
      ],
    );
  }
}