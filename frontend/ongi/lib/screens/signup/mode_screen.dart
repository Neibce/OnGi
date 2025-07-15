import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/familyname_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/services/signup_service.dart';
import 'package:ongi/services/login_service.dart';

class ModeScreen extends StatelessWidget {
  final String username;

  const ModeScreen(this.username, {super.key});

  Future<void> _setModeAndRegister(BuildContext context, String mode) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '회원가입 진행 중이에요...',
          style: TextStyle(color: AppColors.ongiOrange),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_mode', mode);

      final email = prefs.getString('signup_email') ?? '';
      final password = prefs.getString('signup_password') ?? '';
      final name = prefs.getString('signup_username') ?? '';
      final isParent = mode == 'parent';

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '회원가입 정보가 올바르지 않아요.',
              style: TextStyle(color: AppColors.ongiOrange),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final signupService = SignupService();
      await signupService.register(
        email: email,
        password: password,
        name: name,
        isParent: isParent,
      );

      final loginService = LoginService();
      await loginService.login(
        email: email,
        password: password,
      );

      if (!context.mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FamilynameScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '회원가입 또는 로그인 실패: $e',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                    onPressed: () => _setModeAndRegister(context, 'parent'),
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
                    onPressed: () => _setModeAndRegister(context, 'child'),
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