import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/familycode_screen.dart';
import 'package:ongi/screens/signup/familycode_create_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilynameScreen extends StatefulWidget {
  const FamilynameScreen({super.key});

  @override
  State<FamilynameScreen> createState() => _FamilynameScreenState();
}

class _FamilynameScreenState extends State<FamilynameScreen> {
  final TextEditingController _familynameCtrl = TextEditingController();
  bool _isChecked = false;

  Future<void> _handleSubmit() async {
    final familyName = _familynameCtrl.text.trim();
    if (familyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '가족이름을 입력해주세요.',
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

    if (familyName.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '가족이름은 6자 이하여야 해요.',
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

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_name', familyName);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FamilycodeCreateScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
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
                  5,
                  (index) => Container(
                    width: 58,
                    height: 7.5,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.ongiOrange,
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
                    child: Text(
                      '우리가족의',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w200,
                        height: 1.2,
                        color: AppColors.ongiOrange,
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                  Text(
                    '가족이름을\n만들어주세요',
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
              padding: const EdgeInsets.only(left: 40, right: 40, top: 30),
              child: TextField(
                controller: _familynameCtrl,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppColors.ongiOrange,
                ),
                decoration: InputDecoration(
                  hintText: 'FAMILYNAME',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
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
              padding: const EdgeInsets.only(left: 40, right: 30, top: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: AppColors.ongiOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,

                    onChanged: (bool? value) {
                      if (value == null) return;
                      setState(() => _isChecked = value);

                      if (value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FamilycodeScreen(),
                          ),
                        ).then((_) => setState(() => _isChecked = false));
                      }
                    },
                  ),
                  const Text(
                    '이미 가입한 가족이 있어요!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 40, right: 40, bottom: 16),
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
            onPressed: _handleSubmit,
            child: const Text(
              '함께하기',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
