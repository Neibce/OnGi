import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '기록 추가',
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
            Icon(Icons.add_circle, size: 80, color: AppColors.ongiOrange),
            SizedBox(height: 16),
            Text(
              '새 기록 추가',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '건강 상태를 기록해보세요',
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