import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class HomeOngiTextWithoutUser extends StatelessWidget {
  const HomeOngiTextWithoutUser({super.key});

  @override
  Widget build(BuildContext context) {
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
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 60,
                color: AppColors.ongiOrange,
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
