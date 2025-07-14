import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();

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
                      color: index == 0 || index == 1 || index == 2
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
                  children: const [
                    Align(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        '당신을',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w200,
                          height: 1.2,
                          color: AppColors.ongiOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      '어떻게\n부르면\n좋을까요?',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.ongiOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
                child: TextField(
                  controller: _usernameCtrl,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 25, color: AppColors.ongiOrange),
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력해주세요',
                    hintStyle:
                    TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 13),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: AppColors.ongiOrange, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: AppColors.ongiOrange, width: 1),
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
                    onPressed: () async {
                      final username = _usernameCtrl.text.trim();
                      if (username.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이름을 입력해주세요')),
                        );
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('signup_username', username);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModeScreen(username),
                        ),
                      );
                    },
                    child: const Text(
                      '계속하기',
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}
