import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class HomeOngiText extends StatelessWidget {
  final String username;
  const HomeOngiText({required this.username, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$username님',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: AppColors.ongiOrange,
          ),
        ),
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
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              TextSpan(
                text: '온기는',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],

    );
  }
}