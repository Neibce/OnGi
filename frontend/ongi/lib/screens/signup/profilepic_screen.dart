import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  int? _selectedIndex;

  Widget _buildSelectableIcon(String assetPath, int index, {double size = 90}) {
    final bool isSelected = _selectedAsset == assetPath;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAsset = assetPath;
          _selectedIndex = index;
        });
      },
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // 이미지 (원형 클리핑)
              ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.asset(
                  assetPath,
                  width: size,
                  height: size,
                  fit: BoxFit.contain, // 원래 쓰던 contain 유지
                ),
              ),

              if (isSelected)
                Positioned(
                  right: -5,
                  bottom: 0,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      height: 42,
                      padding: EdgeInsets.all(size * 0.08),
                      child: SvgPicture.asset(
                        'assets/images/users/pfp_check_icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
                          : AppColors.ongiOrange.withValues(alpha: 0.4),
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
                    0,
                    size: 107,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/dad_icon.png',
                    1,
                    size: 110,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/daughter_icon.png',
                    2,
                    size: 103,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/son_icon.png',
                    3,
                    size: 98,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/black_woman_icon.png',
                    4,
                    size: 90,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/black_man_icon.png',
                    5,
                    size: 91,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/baby_icon.png',
                    6,
                    size: 96,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/dog_icon.png',
                    7,
                    size: 98,
                  ),
                  _buildSelectableIcon(
                    'assets/images/users/robot_icon.png',
                    8,
                    size: 98,
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
                    if (_selectedIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '프로필 아이콘을 선택해주세요.',
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

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('signup_username', widget.username);
                    await prefs.setInt(
                      'signup_profileImageId',
                      _selectedIndex!,
                    );
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
