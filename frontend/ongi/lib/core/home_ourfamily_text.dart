import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class HomeOngiText extends StatelessWidget {
  const HomeOngiText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 60,
          color: AppColors.ongiOrange,
        ),
        children: const [
          TextSpan(
            text: '우리가족의\n',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: '온기는',
            style: TextStyle(fontWeight: FontWeight.w700), // 굵게!
          ),
        ],
      ),
    );
  }
}