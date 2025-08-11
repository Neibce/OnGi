import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodySelector extends StatelessWidget {
  final Set<String> selectedParts;
  final Function(String part, bool selected) onPartSelected;
  final bool isFront;

  static const Map<String, String> partLabels = {
    'HEAD': '머리',
    'NECK': '목',
    'SHOULDER_LEFT': '왼쪽 어깨',
    'SHOULDER_RIGHT': '오른쪽 어깨',
    'CHEST_LEFT': '왼쪽 가슴',
    'CHEST_RIGHT': '오른쪽 가슴',
    'BACK_LEFT': '왼쪽 등',
    'BACK_RIGHT': '오른쪽 등',
    'ARM_LEFT': '왼쪽 팔',
    'ARM_RIGHT': '오른쪽 팔',
    'HAND_LEFT': '왼손',
    'HAND_RIGHT': '오른손',
    'ABDOMEN_LEFT': '왼쪽 배',
    'ABDOMEN_RIGHT': '오른쪽 배',
    'WAIST_LEFT': '왼쪽 허리',
    'WAIST_RIGHT': '오른쪽 허리',
    'LEG_LEFT': '왼쪽 다리',
    'LEG_RIGHT': '오른쪽 다리',
    'KNEE_LEFT': '왼쪽 무릎',
    'KNEE_RIGHT': '오른쪽 무릎',
    'FOOT_LEFT': '왼발',
    'FOOT_RIGHT': '오른발',
    'NONE': '없음',
  };

  const BodySelector({
    Key? key,
    required this.selectedParts,
    required this.onPartSelected,
    this.isFront = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          isFront
              ? 'assets/images/body_selector.svg'
              : 'assets/images/body_selector_back.svg',
          width: 265,
          height: 500,
        ),
        // 머리 (중앙)
        _buildPartArea(left: 110, top: 10, width: 45, height: 45, part: 'HEAD'),
        // 목 (중앙)
        _buildPartArea(left: 120, top: 55, width: 25, height: 25, part: 'NECK'),
        // 어깨
        _buildPartArea(left: 70, top: 80, width: 35, height: 35, part: 'SHOULDER_LEFT'),
        _buildPartArea(left: 160, top: 80, width: 35, height: 35, part: 'SHOULDER_RIGHT'),
        // 가슴(앞) / 등(뒤)
        if (isFront)
          ...[
            _buildPartArea(left: 95, top: 110, width: 30, height: 35, part: 'CHEST_LEFT'),
            _buildPartArea(left: 140, top: 110, width: 30, height: 35, part: 'CHEST_RIGHT'),
          ]
        else
          ...[
            _buildPartArea(left: 95, top: 110, width: 30, height: 35, part: 'BACK_LEFT'),
            _buildPartArea(left: 140, top: 110, width: 30, height: 35, part: 'BACK_RIGHT'),
          ],
        // 팔
        _buildPartArea(left: 50, top: 120, width: 25, height: 60, part: 'ARM_LEFT'),
        _buildPartArea(left: 190, top: 120, width: 25, height: 60, part: 'ARM_RIGHT'),
        // 손
        _buildPartArea(left: 30, top: 240, width: 25, height: 30, part: 'HAND_LEFT'),
        _buildPartArea(left: 210, top: 240, width: 25, height: 30, part: 'HAND_RIGHT'),
        // 배(앞) / 허리(뒤)
        if (isFront)
          ...[
            _buildPartArea(left: 110, top: 150, width: 25, height: 40, part: 'ABDOMEN_LEFT'),
            _buildPartArea(left: 130, top: 150, width: 25, height: 40, part: 'ABDOMEN_RIGHT'),
          ]
        else
          ...[
            _buildPartArea(left: 110, top: 150, width: 25, height: 40, part: 'WAIST_LEFT'),
            _buildPartArea(left: 130, top: 150, width: 25, height: 40, part: 'WAIST_RIGHT'),
          ],
        // 다리
        _buildPartArea(left: 100, top: 230, width: 25, height: 70, part: 'LEG_LEFT'),
        _buildPartArea(left: 140, top: 230, width: 25, height: 70, part: 'LEG_RIGHT'),
        // 무릎
        _buildPartArea(left: 100, top: 300, width: 25, height: 30, part: 'KNEE_LEFT'),
        _buildPartArea(left: 140, top: 300, width: 25, height: 30, part: 'KNEE_RIGHT'),
        // 발
        _buildPartArea(left: 100, top: 400, width: 25, height: 35, part: 'FOOT_LEFT'),
        _buildPartArea(left: 140, top: 400, width: 25, height: 35, part: 'FOOT_RIGHT'),
      ],
    );
  }

  Widget _buildPartArea({
    required double left,
    required double top,
    required double width,
    required double height,
    required String part,
  }) {
    final isSelected = selectedParts.contains(part);
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onPartSelected(part, !isSelected),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.4),
                    shape: BoxShape.rectangle,
                  ),
                ),
              // 한글명 표시 (중앙 하단)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    partLabels[part] ?? part,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.white70,
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
}