import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, -0.5),
              end  : Alignment(-1.0, 1.0),
              colors: [
                AppColors.ongiBlue,
                AppColors.ongiOrange,
              ],
              stops: [0.0, 0.6]
            ),
          ),
        ),

        Positioned(
          left: -50,
          bottom: 80,
          child: Opacity(
            opacity: 0.55,
            child: Image.asset(
              'assets/images/logo.png',
              width: 400,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
