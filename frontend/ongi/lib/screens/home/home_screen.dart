import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
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
          Positioned(
            bottom: -MediaQuery.of(context).size.width * 0.6,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.5,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: AppColors.ongiLigntgrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(260),
                      topRight: Radius.circular(260),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Background logo (top right)
          const HomeBackgroundLogo(),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.14),
                HomeOngiText(username: _username),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                HomeCapsuleSection(),
              ],
            ),
        ],
      ),
    );
  }
}