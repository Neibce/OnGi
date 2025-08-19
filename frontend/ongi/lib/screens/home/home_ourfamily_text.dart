import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ongi/utils/prefs_manager.dart';

class HomeOngiText extends StatelessWidget {
  final String username;

  const HomeOngiText({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth * 0.08;

    return Padding(
      padding: EdgeInsets.only(
        left: 32,
        right: 0, // 오른쪽 패딩 제거
        top: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: PrefsManager.getUserInfo(),
                builder: (context, snapshot) {
                  final userInfo = snapshot.data ?? {};
                  final profileImageId = userInfo['profileImageId'] ?? 0;
                  final profileImagePath = PrefsManager.getProfileImagePath(profileImageId);
                  
                  return Image.asset(
                    profileImagePath,
                    width: iconSize,
                    height: iconSize,
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '$username님',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 60,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: '우리가족의\n',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
                TextSpan(
                  text: '온기는',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
