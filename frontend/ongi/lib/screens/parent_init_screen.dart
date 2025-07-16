import 'package:flutter/material.dart';
import 'package:ongi/screens/health_log_screen.dart';
import 'package:ongi/screens/home/home_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/core/app_background.dart';

class ParentInitScreen extends StatelessWidget {
  const ParentInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '지금,\n온기를',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '더해볼까요?',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HealthLogScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(160, 200),
                        padding: const EdgeInsets.all(24),
                        foregroundColor: AppColors.ongiOrange,
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('건강\n기록', textAlign: TextAlign.left),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(160, 200),
                        padding: const EdgeInsets.all(24),
                        foregroundColor: AppColors.ongiOrange,
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('홈', textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
