import 'package:flutter/material.dart';
import 'package:ongi/screens/health/health_home_screen.dart';
import 'package:ongi/screens/login/login_pw_screen.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/screens/bottom_nav.dart';
import 'package:ongi/screens/signup/password_screen.dart';

void main() {
  runApp(const OngiApp());
}

class OngiApp extends StatelessWidget {
  const OngiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ongi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),

      home: const BottomNavScreen(),

      routes: {
        '/login': (context) => const LoginPwScreen(),
        '/signup': (context) => const PasswordScreen(),
      }
    );
  }
}
