import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/ready_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/services/code_service.dart';

class FamilycodeCreateScreen extends StatefulWidget {
  const FamilycodeCreateScreen({super.key});

  @override
  State<FamilycodeCreateScreen> createState() => _FamilycodeCreateScreenState();
}

class _FamilycodeCreateScreenState extends State<FamilycodeCreateScreen> {
  final TextEditingController _familycodeCtrl = TextEditingController();
  bool _isCodeGenerated = false;

  Future<void> _handleSubmit() async {
    if (_isCodeGenerated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReadyScreen()),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final familyName = prefs.getString('family_name') ?? '';

      final codeService = CodeService();
      final response = await codeService.familyCreate(name: familyName);

      final code = response['code'];
      if (code != null) {
        setState(() {
          _familycodeCtrl.text = code;
          _isCodeGenerated = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '코드 생성에 실패하였습니다..',
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '코드 생성 실패 : $e',
            style: const TextStyle(color: AppColors.ongiOrange),
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
                    '가족코드를\n생성해볼까요?',
                    style: TextStyle(
                      fontSize: 59,
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
                controller: _familycodeCtrl,
                readOnly: true,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppColors.ongiOrange,
                ),
                decoration: InputDecoration(
                  hintText: 'FAMILYCODE',
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
                  onPressed: _handleSubmit,
                  child: Text(
                    _isCodeGenerated ? '함께하기' : '생성하기',
                    style: const TextStyle(
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
