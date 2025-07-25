import 'package:flutter/material.dart';
import 'package:ongi/core/app_orange_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/svg.dart';

class PhotoRemindPopup extends StatelessWidget {
  const PhotoRemindPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppOrangeBackground(
        child: Stack(
          children: [
            Positioned(
              top: 80,
              right: 30,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/close_icon_white.svg',
                  width: 28,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                iconSize: 36,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 160, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '가족들이',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w200,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '사진을\n올리지\n않았어요!',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 170,
                      right: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '가족들에게 푸시 알림을 전송할까요?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(double.infinity, 35),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // 마음 기록 입력 화면 완성하고 수정
                          },
                          child: const Text(
                            '재촉하기!',
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w400,
                              color: AppColors.ongiOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
