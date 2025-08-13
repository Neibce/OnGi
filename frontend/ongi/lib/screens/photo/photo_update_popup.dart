import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/core/app_orange_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/screens/bottom_nav.dart';

class PhotoUpdatePopup extends StatelessWidget {
  const PhotoUpdatePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: AppOrangeBackground(
            child: Stack(
              children: [
                Positioned(
                  top: 80,
                  right: 30,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/close_icon_white.svg',
                      width: 28,
                    ),
                    iconSize: 36,
                    onPressed: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) =>
                                const BottomNavScreen(initialIndex: 0),
                          ),
                          (route) => route.isFirst,
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 160, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '가족들도',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w200,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '사진을\n올렸어요!',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          top: 180,
                          right: 10,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(double.infinity, 35),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BottomNavScreen(initialIndex: 2),
                                ),
                                (route) => route.isFirst,
                              );
                            });
                          },
                          child: const Text(
                            '보러가기!',
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w400,
                              color: AppColors.ongiOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
