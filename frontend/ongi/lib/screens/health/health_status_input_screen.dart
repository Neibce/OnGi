import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import '../../core/app_colors.dart';
import '../../widgets/date_carousel.dart';
import '../../services/pain_service.dart';
import 'package:intl/intl.dart';

class HealthStatusInputScreen extends StatefulWidget {
  const HealthStatusInputScreen({super.key});

  @override
  State<HealthStatusInputScreen> createState() => _HealthStatusInputScreenState();
}

class _HealthStatusInputScreenState extends State<HealthStatusInputScreen> {
  BodyParts _bodyParts = const BodyParts();
  DateTime selectedDate = DateTime.now();
  bool isFrontView = true;

  // 신체 부위 선택 처리
  void onBodyPartsSelected(BodyParts parts) {
    setState(() {
      _bodyParts = parts;
    });
  }

  // 선택된 부위가 있는지 확인
  bool get hasSelectedParts {
    return _bodyParts.toString().contains('true');
  }

  // 앞/뒤 전환 메서드
  void toggleView() {
    setState(() {
      isFrontView = !isFrontView;
    });
  }

  // BodyParts를 API enum으로 매핑
  List<PainArea> _getSelectedPainAreas() {
    List<PainArea> painAreas = [];
    
    // BodyParts 구조 디버깅
    print('BodyParts object: $_bodyParts');
    print('BodyParts toString: ${_bodyParts.toString()}');
    
    // 안전한 방법으로 확인
    final bodyPartsString = _bodyParts.toString();
    
    // 각 부위별로 문자열에서 찾아서 체크
    if (bodyPartsString.contains('head: true')) painAreas.add(PainArea.head);
    if (bodyPartsString.contains('neck: true')) painAreas.add(PainArea.neck);
    if (bodyPartsString.contains('shoulder') && bodyPartsString.contains('true')) painAreas.add(PainArea.shoulder);
    if (bodyPartsString.contains('chest: true')) painAreas.add(PainArea.chest);
    if (bodyPartsString.contains('pelvis: true') || bodyPartsString.contains('back: true')) painAreas.add(PainArea.back);
    if (bodyPartsString.contains('arm') && bodyPartsString.contains('true')) painAreas.add(PainArea.arm);
    if (bodyPartsString.contains('hand') && bodyPartsString.contains('true')) painAreas.add(PainArea.hand);
    if (bodyPartsString.contains('stomach: true') || bodyPartsString.contains('abdomen: true')) painAreas.add(PainArea.abdomen);
    if (bodyPartsString.contains('hip') && bodyPartsString.contains('true')) painAreas.add(PainArea.waist);
    if (bodyPartsString.contains('leg') && bodyPartsString.contains('true')) painAreas.add(PainArea.leg);
    if (bodyPartsString.contains('knee') && bodyPartsString.contains('true')) painAreas.add(PainArea.knee);
    if (bodyPartsString.contains('foot') && bodyPartsString.contains('true') || 
        bodyPartsString.contains('ankle') && bodyPartsString.contains('true')) painAreas.add(PainArea.foot);
    
    print('Selected pain areas: $painAreas');
    
    // 중복 제거
    return painAreas.toSet().toList();
  }

  // 통증 기록 저장
  void submitPainRecords() async {
    // 토큰 확인
    final token = await PrefsManager.getAccessToken();
    print('Current access token: $token');
    
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인해주세요.')),
      );
      return;
    }
    
    final painAreas = _getSelectedPainAreas();
    
    if (painAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('통증 부위를 선택해주세요.')),
      );
      return;
    }

    // 로딩 상태 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
      
      // 여러 부위가 선택된 경우 각각 개별 API 호출
      for (final painArea in painAreas) {
        final result = await PainService.addPainRecord(
          date: dateString,
          painArea: painArea.value,
          painLevel: PainLevel.midWeak.value, // 기본값으로 설정 (추후 사용자 선택 가능)
        );
        
        if (result == null) {
          throw Exception('통증 기록 저장에 실패했습니다.');
        }
      }
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('통증 기록이 저장되었습니다. (${painAreas.length}개 부위)'),
          backgroundColor: AppColors.ongiOrange,
        ),
      );
      
      // 선택 초기화
      setState(() {
        _bodyParts = const BodyParts();
      });
      
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 상단 원형 배경
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

            // 본문
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
                        margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: BodyPartSelector(
                                bodyParts: _bodyParts,
                                onSelectionUpdated: (p) => setState(() => _bodyParts = p),
                                side: isFrontView ? BodySide.front : BodySide.back,
                                selectedColor: AppColors.ongiOrange,
                              ),
                            ),
                    
                    //기록완료 버튼
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasSelectedParts ? AppColors.ongiOrange : Colors.grey[300],
                          border: Border.all(
                            color: hasSelectedParts ? AppColors.ongiOrange : Colors.grey[400]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: hasSelectedParts ? submitPainRecords : null,
                          child: Center(
                            child: Text(
                              '완료',
                              style: TextStyle(
                                color: hasSelectedParts ? Colors.white : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 앞뒤 전환 버튼 (오른쪽 하단)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFrontView ? Colors.white : AppColors.ongiOrange,
                          border: Border.all(
                            color: AppColors.ongiOrange,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: toggleView,
                          child: Center(
                            child: Text(
                              isFrontView ? '앞' : '뒤',
                              style: TextStyle(
                                color: isFrontView ? AppColors.ongiOrange : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                          ],
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
    );
  }
}