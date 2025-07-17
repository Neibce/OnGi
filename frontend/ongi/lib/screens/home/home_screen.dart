import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/home/home_logo.dart';
import 'package:ongi/screens/home/home_ourfamily_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/screens/home/home_donutCapsule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '사용자';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('signup_username');
    if (savedUsername != null) {
      setState(() {
        _username = savedUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ongiOrange,
      body: Stack(
        children: [
          // Background logo (top right)
          const HomeBackgroundLogo(),
          Positioned(
            child: CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width *1.5,
                MediaQuery.of(context).size.width *1.5,
              ),
              painter: Painter(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeOngiText(username: _username),
                HomeCapsuleSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Painter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    final double rectWidth = size.width * 1.5;
    final double rectHeight = size.width * 1.5;

    final double left = size.width * -0.2;
    final double top = size.height * 0.6;

    final rect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(255));

    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFFF7F7F7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}