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
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),

                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // 본문 내용
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40, top: 25, bottom: 20),
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
                                  text: '77,804걸음', // 예시 총 걸음수
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 40,
                                    color: Color(0xFFFD6C01),
                                  ),
                                ),
                                TextSpan(
                                  text: ' 걸었어요!',
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
                          const SizedBox(height: 30),
                          // 가족별 걸음수 리스트 스크롤
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildStepMember(
                                    context: context,
                                    name: '양은명',
                                    steps: 28301,
                                    image: 'assets/images/users/elderly_woman.png',
                                    isTop: true,
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '오애순',
                                    steps: 20315,
                                    image: 'assets/images/users/elderly_woman.png',
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '양관식',
                                    steps: 17336,
                                    image: 'assets/images/users/elderly_woman.png',
                                  ),
                                  _buildStepMember(
                                    context: context,
                                    name: '양금명',
                                    steps: 11852,
                                    image: 'assets/images/users/elderly_woman.png',
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}


Widget _buildStepMember({required BuildContext context, required String name, required int steps, required String image, bool isTop = false}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 프로필 이미지 (pill 왼쪽)
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 70,
              height: 80,
              child: ClipOval(
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            if (isTop)
              Positioned(
                left: -12,
                top: -20,
                child: SizedBox(
                  width: 42,
                  height: 32,
                  child: SvgPicture.asset('assets/images/step_tracker_crown.svg'),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // pill형 Container (radius 20, 오렌지)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFD6C01),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Spacer(),
                    Text(
                      steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 40,
                        height: 0.7,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '걸음',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
