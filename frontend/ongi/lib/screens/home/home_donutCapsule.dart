import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeCapsuleSection extends StatelessWidget {
  const HomeCapsuleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.17
              ),

              child: Transform.translate(

                offset: Offset(MediaQuery.of(context).size.width * 0.35, 0),
                child: ButtonColumn(),
              ),
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
  final String notificationText;

  const CapsuleButton({
    required this.svgAsset,
    required this.selected,
    required this.onTap,
    required this.notificationText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FractionallySizedBox(
        widthFactor: selected ? 2.9 : 1.0, // 선택 시 2.8배, 아니면 1.0배
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 68,
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
              const SizedBox(width: 20),
              SvgPicture.asset(
                svgAsset,
                width: MediaQuery.of(context).size.width * 0.07,
                height: MediaQuery.of(context).size.width * 0.07,
                colorFilter: ColorFilter.mode(
                  selected ? Colors.white : AppColors.ongiOrange,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  notificationText,
                  overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.ongiOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
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
            notificationText: selectedIdx == 0 ? '23분 뒤, 이부프로펜 1알 섭취 예정' : '알림이 없어요',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_med.svg',
            selected: selectedIdx == 1,
            onTap: () => setState(() => selectedIdx = 1),
            notificationText: selectedIdx == 1 ? '오늘의 통증 부위: 허리, 오른쪽 무릎' : '알림이 없어요',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_walk.svg',
            selected: selectedIdx == 2,
            onTap: () => setState(() => selectedIdx = 2),
            notificationText: selectedIdx == 2 ? '12,000 걸음' : '알림이 없어요',
          ),
        ],
      ),
    );
  }
}