import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/date_carousel.dart';
import '../../widgets/body_selector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/prefs_manager.dart';

class HealthStatusInputScreen extends StatefulWidget {
  const HealthStatusInputScreen({super.key});

  @override
  State<HealthStatusInputScreen> createState() =>
      _HealthStatusInputScreenState();
}

class _HealthStatusInputScreenState extends State<HealthStatusInputScreen> {
  Map<int, int> selectedDosages = {};
  bool isFront = true;
  Set<String> selectedParts = {};
  Map<String, String> painLevels = {}; // 부위별 통증 강도
  DateTime selectedDate = DateTime.now();

  static const List<String> painLevelOptions = [
    'STRONG', 'MID_STRONG', 'MID_WEAK', 'WEAK'
  ];

  Future<void> submitPainRecords() async {
    final accessToken = await PrefsManager.getAccessToken();
    final url = Uri.parse('https://ongi-1049536928483.asia-northeast3.run.app/health/pain/record');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer 80eb477a6e3a43e681d317b25f5f3f9e',
    };
    for (final part in selectedParts) {
      final level = painLevels[part] ?? 'WEAK';
      final body = jsonEncode({
        'date': selectedDate.toIso8601String().substring(0, 10),
        'painArea': part,
        'painLevel': level,
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200) {
        // 실패 처리 (에러 메시지 표시 등)
        print('Failed to save $part: \\${response.body}');
      }
    }
    // 완료 처리 (예: 완료 메시지, 화면 이동 등)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('통증 기록이 저장되었습니다.')),
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
                              child: BodySelector(
                                selectedParts: selectedParts,
                                onPartSelected: (part, selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedParts.add(part);
                                    } else {
                                      selectedParts.remove(part);
                                      painLevels.remove(part);
                                    }
                                  });
                                },
                                isFront: isFront,
                              ),
                            ),
                            // 선택된 부위별 통증 강도 선택 UI
                            if (selectedParts.isNotEmpty)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 20,
                                child: Column(
                                  children: selectedParts.map((part) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          part,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value: painLevels[part] ?? 'WEAK',
                                          items: painLevelOptions.map((level) => DropdownMenuItem(
                                            value: level,
                                            child: Text(level),
                                          )).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              painLevels[part] = val!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFront = !isFront;
                                  });
                                },
                                child: SvgPicture.asset(
                                  isFront
                                      ? 'assets/images/body_selector_front.svg'
                                      : 'assets/images/body_selector_back.svg',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 기록하기 버튼
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
