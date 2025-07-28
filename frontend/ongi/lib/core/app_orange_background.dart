import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/svg.dart';

class AppOrangeBackground extends StatelessWidget {
  final Widget child;
  const AppOrangeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.ongiOrange),
        Positioned(
          left: -45,
          bottom: 80,
          child: SvgPicture.asset(
            'assets/images/logo_white.svg',
            width: 380,
            fit: BoxFit.contain,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
