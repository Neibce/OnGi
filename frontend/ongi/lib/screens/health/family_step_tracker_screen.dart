import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FamilyStepTrackerScreen extends StatefulWidget {
  const FamilyStepTrackerScreen({super.key});

  @override
  State<FamilyStepTrackerScreen> createState() =>
      _FamilyStepTrackerScreenState();
}

class _FamilyStepTrackerScreenState extends State<FamilyStepTrackerScreen> {
  Map<int, int> selectedDosages = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return Scaffold(
      backgroundColor: AppColors.ongiLigntgrey,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -circleSize * 0.76),
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ongiOrange,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: circleSize * 0.86),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                '오늘 걸은 만큼 건강도 쌓였습니다.',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '잘하셨어요!',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                child: Image.asset(
                                  'assets/images/step_tracker_title_logo.png',
                                  width: circleSize * 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: circleSize * 0.43,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // 배경 SVG
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/images/step_tracker_light_background.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    // 본문 내용
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘 우리 가족은',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFFFD6C01),
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '총 ',
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: Color(0xFFFD6C01),
                                  ),
                                ),
                                TextSpan(
                                  text: '77,804', // 예시 총 걸음수
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 40,
                                    color: Color(0xFFFD6C01),
                                  ),
                                ),
                                TextSpan(
                                  text: '걸음 걸었어요!',
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: Color(0xFFFD6C01),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height:50),
                          // 가족별 걸음수 리스트
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final pillWidth = constraints.maxWidth;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildStepMember(
                                    context: context,
                                    name: '양은명',
                                    steps: 28301,
                                    image: 'assets/images/users/elderly_woman.png',
                                    isTop: true,
                                    pillWidth: pillWidth,
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '오애순',
                                    steps: 20315,
                                    image: 'assets/images/users/elderly_woman.png',
                                    pillWidth: pillWidth,
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '양관식',
                                    steps: 17336,
                                    image: 'assets/images/users/elderly_woman.png',
                                    pillWidth: pillWidth,
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '양금명',
                                    steps: 11852,
                                    image: 'assets/images/users/elderly_woman.png',
                                    pillWidth: pillWidth,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _buildStepMember 완전 새로 구현
Widget _buildStepMember({required BuildContext context, required String name, required int steps, required String image, bool isTop = false, required double pillWidth}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 프로필 이미지 (pill 왼쪽)
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 55,
              height: 65,
              child: ClipOval(
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            if (isTop)
              Positioned(
                left: 0,
                top: -20,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset('assets/images/step_tracker_crown.svg'),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // pill형 Container (radius 20, 오렌지)
        Expanded(
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Color(0xFFFD6C01),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '걸음',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
