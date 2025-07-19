import 'package:flutter/material.dart';
import 'package:ongi/core/app_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/bottom_nav.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 150, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '우리 가족,',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 80),
              const Text(
                '더 따뜻해질\n준비\n되셨나요?',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 45, right: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 35),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNavScreen()),
                        (Route<dynamic> route) => false,
                  ),
                  child: const Text(
                    '준비완료!',
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}