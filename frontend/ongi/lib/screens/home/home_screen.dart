import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/core/home_logo.dart';
import 'package:ongi/core/home_ourfamily_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background logo (top right)
          const HomeBackgroundLogo(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const HomeOngiText(),

                const SizedBox(height: 88),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          // 도넛 위치
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Transform.translate(
                            offset: Offset(MediaQuery.of(context).size.width * 0.3, 0),
                            child: ButtonColumn(),
                          ),
                        ),
                      ),
                    ],
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


class CapsuleButton extends StatelessWidget {
  final String svgAsset;
  final bool selected;
  final VoidCallback onTap;

  const CapsuleButton({
    required this.svgAsset,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FractionallySizedBox(
        widthFactor: selected ? 1.2 : 1.0, // 선택 시 더 길게 (2.8)
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 72,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.ongiOrange : Colors.white,
            border: Border.all(
              color: AppColors.ongiOrange,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(39),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.ongiOrange,
                offset: Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              SizedBox(width: 20),
              SvgPicture.asset(
                svgAsset,
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  selected ? Colors.white : AppColors.ongiOrange,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonColumn extends StatefulWidget {
  const ButtonColumn({super.key});
  @override
  State<ButtonColumn> createState() => _ButtonColumnState();
}

class _ButtonColumnState extends State<ButtonColumn> {
  int selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min, // overflow 방지
        children: [
          CapsuleButton(
            svgAsset: 'assets/images/homebar_capsule.svg',
            selected: selectedIdx == 0,
            onTap: () => setState(() => selectedIdx = 0),
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_med.svg',
            selected: selectedIdx == 1,
            onTap: () => setState(() => selectedIdx = 1),
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_walk.svg',
            selected: selectedIdx == 2,
            onTap: () => setState(() => selectedIdx = 2),
          ),
        ],
      ),
    );

  }
}
