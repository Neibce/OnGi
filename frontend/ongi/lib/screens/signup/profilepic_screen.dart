import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/signup/mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilepicScreen extends StatefulWidget {
  final String username;
  const ProfilepicScreen(this.username, {super.key});

  @override
  State<ProfilepicScreen> createState() => _ProfilepicScreenState();
}

class _ProfilepicScreenState extends State<ProfilepicScreen> {
  String? _selectedAsset;

  Widget _buildSelectableIcon(String assetPath, {double size = 90}) {
    bool isSelected = _selectedAsset == assetPath;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAsset = assetPath;
        });
      },
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.ongiOrange : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
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
                  const Text(
                    '아이콘을',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w200,
                      height: 1.2,
                      color: AppColors.ongiOrange,
                    ),
                  ),
                  const Text(
                    '선택해주세요',
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
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _buildSelectableIcon(
                    'assets/images/users/mom_icon.png',
                    size: 98,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/dad_icon.png',
                    size: 105,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/daughter_icon.png',
                    size: 120,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/son_icon.png',
                    size: 98,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/black_woman_icon.png',
                    size: 90,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/black_man_icon.png',
                    size: 89,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/baby_icon.png',
                    size: 88,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/dog_icon.png',
                    size: 98,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/robot_icon.png',
                    size: 88,
                  ),
                ],
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('signup_username', widget.username);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModeScreen(widget.username),
                      ),
                    );
                  },
                  child: const Text(
                    '등록하기',
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
