import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeOngiText extends StatelessWidget {
  final String username;
  const HomeOngiText({required this.username, super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth * 0.08;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/users/elderly_woman.svg',
              width: iconSize,
              height: iconSize,
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