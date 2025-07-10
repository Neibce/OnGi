import 'package:flutter/material.dart';

class FamilyTempbarScreen extends StatelessWidget {
  const FamilyTempbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '가족',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '가족 화면',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '가족 구성원 관리',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
