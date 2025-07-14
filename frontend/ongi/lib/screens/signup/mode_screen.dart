import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/familyname_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeScreen extends StatelessWidget {
  final String username;

  const ModeScreen(this.username, {super.key});

  Future<void> _setModeAndNavigate(BuildContext context, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_mode', mode);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FamilynameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 100, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5, (index) => Container(
                  width: 58,
                  height: 7.5,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: index != 4
                        ? AppColors.ongiOrange
                        : AppColors.ongiOrange.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$username님은',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                  const SizedBox(height: 100),
                  const Text(
                    '  부모모드와 자녀모드 중 선택해주세요',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _setModeAndNavigate(context, 'parent'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(155, 190),
                      padding: const EdgeInsets.all(24),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.ongiOrange,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("부모"),
                  ),
                  const SizedBox(width: 25),
                  ElevatedButton(
                    onPressed: () => _setModeAndNavigate(context, 'child'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(155, 190),
                      padding: const EdgeInsets.all(24),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.ongiOrange,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("자녀"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 100),
              child: Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  '입니다',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                )
              )
            )
          ]
        ),
      ),
    );
  }
}