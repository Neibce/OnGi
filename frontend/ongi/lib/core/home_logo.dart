import 'package:flutter/material.dart';

class HomeBackgroundLogo extends StatelessWidget {
  const HomeBackgroundLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Positioned(
          top: -screenHeight * 0.16,
          right: -screenWidth * 0.5,
          child: Opacity(
            opacity: 0.30,
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 1.2,
              height: screenWidth * 1.2,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
