import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '프로필 화면',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '사용자 정보 및 설정',
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