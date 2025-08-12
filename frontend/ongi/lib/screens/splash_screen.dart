import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/bottom_nav.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/utils/prefs_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startInitializationFlow();
  }

  Future<void> _startInitializationFlow() async {
    const minimumSplashDuration = Duration(milliseconds: 1200);

    final hasTokenFuture = PrefsManager.hasAccessToken();
    final delayFuture = Future<void>.delayed(minimumSplashDuration);

    final hasToken = await hasTokenFuture;
    await delayFuture;

    if (!mounted) return;
    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const StartScreen()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/splash_icon.png', height: 124),
                const SizedBox(height: 200),
                const Text(
                  '온기',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ongiOrange,
                    fontSize: 32,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'ONGI',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: AppColors.ongiOrange,
                    fontSize: 32,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
