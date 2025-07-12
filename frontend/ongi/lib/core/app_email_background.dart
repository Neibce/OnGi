import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class AppEmailBackground extends StatelessWidget {
  final Widget child;
  const AppEmailBackground({super.key, required this.child});

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
        child,
      ],
    );
  }
}
