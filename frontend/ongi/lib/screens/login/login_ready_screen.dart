import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ongi/core/app_background.dart';
import 'package:ongi/screens/bottom_nav.dart';
import 'package:ongi/screens/tutorial_screen.dart';

class LoginReadyScreen extends StatefulWidget {
  final String username;

  const LoginReadyScreen({required this.username, super.key});

  @override
  State<LoginReadyScreen> createState() => _LoginReadyScreenState();
}

class _LoginReadyScreenState extends State<LoginReadyScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      
      // 튜토리얼 화면 표시 (매번 표시)
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TutorialScreen(
            imageAssets: List.generate(10, (i) => 'assets/images/tutorial/tutorial${i + 1}.png'),
          ),
          fullscreenDialog: true,
        ),
      );
      
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '반가워요',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w200,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.username}님',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
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
