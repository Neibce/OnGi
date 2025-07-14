import 'package:flutter/material.dart';
import 'package:ongi/screens/parent_init_screen.dart';
import 'package:ongi/screens/health_log_screen.dart';
import 'package:ongi/screens/home_screen.dart';
import 'package:ongi/screens/login_screen.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/screens/signup/password_screen.dart';
import 'package:ongi/screens/bottom_nav.dart';

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

      home: const StartScreen(),

      routes: {
        // '/login': (context) => const LoginScreen(),
        '/signup': (context) => const PasswordScreen(),
      }
    );
  }
}
