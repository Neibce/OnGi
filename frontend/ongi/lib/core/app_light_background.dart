import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class AppLightBackground extends StatelessWidget {
  final Widget child;
  const AppLightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.ongiLigntgrey,
        ),
        Positioned(
          right: -140,
          top: -160,
          child: Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/images/logo.png',
              width: 350,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
