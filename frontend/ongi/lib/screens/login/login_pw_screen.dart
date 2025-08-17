import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/services/login_service.dart';
import 'package:ongi/screens/login/login_ready_screen.dart';

class LoginPwScreen extends StatefulWidget {
  const LoginPwScreen({super.key});

  @override
  State<LoginPwScreen> createState() => _LoginPwScreenState();
}

class _LoginPwScreenState extends State<LoginPwScreen> {
  final TextEditingController _passwordCtrl = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;
  bool _obscureText = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.ongiOrange),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
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
              padding: const EdgeInsets.only(left: 30, right: 30, top: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  const Text(
                    '비밀번호를',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                  const Text(
                    '입력해주세요',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w200,
                      height: 1.2,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
              child: Text(
                '반갑습니다!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
              child: TextField(
                obscureText: _obscureText,
                controller: _passwordCtrl,
                keyboardType: TextInputType.visiblePassword,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppColors.ongiOrange,
                ),
                decoration: InputDecoration(
                  hintText: 'PASSWORD',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.ongiOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.ongiOrange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.ongiOrange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: AppColors.ongiOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final password = _passwordCtrl.text.trim();
                          if (password.isEmpty) {
                            _showErrorSnackBar('비밀번호를 입력해주세요.');
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final email = prefs.getString('signup_email') ?? '';

                            final result = await _loginService.login(
                              email: email,
                              password: password,
                            );

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginReadyScreen(
                                  username: result['userInfo']['name'] ?? '사용자',
                                ),
                              ),
                            );
                          } catch (e) {
                            _showErrorSnackBar(
                              '로그인에 실패했어요.T_T 비밀번호를 다시 확인해주세요.',
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.ongiOrange,
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
