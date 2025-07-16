import 'package:flutter/material.dart';

class HomeBackgroundLogo extends StatelessWidget {
  const HomeBackgroundLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -200,
          child: Opacity(
            opacity: 0.30,
            child: Image.asset(
              'assets/images/logo.png',
              width: 480,
              height: 480,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
