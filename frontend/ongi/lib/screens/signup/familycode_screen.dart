import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/ready_screen.dart';
import 'package:ongi/services/family_join_service.dart';

class FamilycodeScreen extends StatefulWidget {
  const FamilycodeScreen({super.key});

  @override
  State<FamilycodeScreen> createState() => _FamilycodeScreenState();
}

class _FamilycodeScreenState extends State<FamilycodeScreen> {
  final TextEditingController _familycodeCtrl = TextEditingController();
  final FamilyJoinService _familyJoinService = FamilyJoinService();
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  Future<void> _handleSubmit() async {
    final familyCode = _familycodeCtrl.text.trim();
    if (familyCode.isEmpty) {
      _showErrorSnackBar('가족코드를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _familyJoinService.familyJoin(code: familyCode);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadyScreen()),
      );
    } catch (e) {
      _showErrorSnackBar('존재하지 않는 가족이에요.');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    '가족코드를\n입력해주세요',
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
                controller: _familycodeCtrl,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppColors.ongiOrange,
                ),
                decoration: InputDecoration(
                  hintText: 'FAMILYCODE',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
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
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.ongiOrange)
                      : const Text(
                          '입력하기',
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
