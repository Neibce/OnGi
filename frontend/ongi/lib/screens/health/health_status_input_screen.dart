import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/date_carousel.dart';
import 'package:body_part_selector/body_part_selector.dart';

class HealthStatusInputScreen extends StatefulWidget {
  const HealthStatusInputScreen({super.key});

  @override
  State<HealthStatusInputScreen> createState() => _HealthStatusInputScreenState();
}

class _HealthStatusInputScreenState extends State<HealthStatusInputScreen> {
  Set<BodyParts> selectedParts = {};
  Map<String, String> painLevels = {};
  DateTime selectedDate = DateTime.now();

  static const List<String> painLevelOptions = [
    'STRONG', 'MID_STRONG', 'MID_WEAK', 'WEAK'
  ];

  void submitPainRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('통증 기록이 저장되었습니다. (화면용 더미 동작)')),
    );
  }

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
                                '어느 곳이',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '불편하세요?',
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
                                  'assets/images/sitting_mom_icon.png',
                                  width: 110,
                                  height: 110,
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
              top: circleSize * 0.3 + 65,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: DateCarousel()),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 80,
                          right: 80,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: BodyPartSelectorTurnable(
                                bodyParts: selectedParts,
                                onSelectionUpdated: (parts) {
                                  setState(() {
                                    selectedParts = parts;
                                  });
                                },
                              ),
                            ),
                            // 앞/뒤 변환 버튼 (토글 텍스트)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.ongiOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                ),
                                onPressed: () {
                                  // BodyPartSelectorTurnable은 자체적으로 앞/뒤 전환을 지원하므로 별도 isFront 관리 불필요
                                },
                                child: const Text('앞/뒤', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: selectedParts.isEmpty ? null : submitPainRecords,
                      child: const Text('기록하기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
