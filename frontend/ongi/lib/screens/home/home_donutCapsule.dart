import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/custom_chart_painter.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/services/temperature_service.dart';

class HomeCapsuleSection extends StatefulWidget {
  final VoidCallback? onGraphTap;
  const HomeCapsuleSection({super.key, this.onGraphTap});

  @override
  State<HomeCapsuleSection> createState() => _HomeCapsuleSectionState();
}

class _HomeCapsuleSectionState extends State<HomeCapsuleSection> {
  double? todayTemperature;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayTemperature();
  }

  Future<void> fetchTodayTemperature() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      if (familyCode == null) throw Exception('가족 코드가 없습니다.');
      final token = await PrefsManager.getAccessToken();
      final service = TemperatureService(baseUrl: 'https://ongi-1049536928483.asia-northeast3.run.app');
      final dailyTemps = await service.fetchFamilyTemperatureDaily(familyCode, token: token);
      final today = DateTime.now();
      final todayStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final match = dailyTemps.firstWhere(
            (e) => e['date'] == todayStr,
        orElse: () => <String, dynamic>{},
      );
      setState(() {
        todayTemperature = match.isNotEmpty ? (match['totalTemperature'] ?? 36.5) : 36.5;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        todayTemperature = 36.5;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // 도넛 차트 영역
          Positioned(
            left: 0,
            bottom: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.95,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: widget.onGraphTap,
                    child: Transform.translate(
                      offset: Offset(
                        -MediaQuery.of(context).size.width * 0.35,
                        0,
                      ),
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: CustomPaint(
                          painter: CustomChartPainter(
                            percentages: [15, 10, 20, 20],
                          ),
                          size: Size(
                            MediaQuery.of(context).size.width * 0.95,
                            MediaQuery.of(context).size.width * 0.95,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 텍스트 (화면 안에 있음)
                Positioned(
                  left:
                  MediaQuery.of(context).size.width *
                      0.04,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          todayTemperature?.toStringAsFixed(1) ?? '36.5',
                          style: TextStyle(
                            fontSize: 43,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ongiOrange,
                            height: 1,
                          ),
                        ),
                        Text(
                          '℃',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ongiOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: ButtonColumn(),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: MediaQuery.of(context).size.width * 0.18,
        width: selected
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.17,
        margin: const EdgeInsets.only(top: 2, bottom: 2, left: 0, right: 0),
        decoration: BoxDecoration(
          color: selected ? AppColors.ongiOrange : AppColors.ongiLigntgrey,
          border: Border(
            top: BorderSide(color: AppColors.ongiOrange, width: 2),
            bottom: BorderSide(color: AppColors.ongiOrange, width: 2),
            left: BorderSide(color: AppColors.ongiOrange, width: 2),
            right: BorderSide.none, // 오른쪽 테두리 제거
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(39),
            bottomLeft: Radius.circular(39),
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.ongiOrange, offset: Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SvgPicture.asset(
              svgAsset,
              width: MediaQuery.of(context).size.width * 0.07,
              height: MediaQuery.of(context).size.width * 0.07,
              // colorFilter: ColorFilter.mode(
              //   selected ? Colors.white : AppColors.ongiOrange,
              //   BlendMode.srcIn,
              // ),
            ),
            if (selected && notificationText.isNotEmpty) ...[
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      notificationText,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
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
  int selectedIdx = -1; // 초기값을 -1로 변경 (아무것도 선택되지 않은 상태)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min, // overflow 방지
        crossAxisAlignment: CrossAxisAlignment.end, // 오른쪽 정렬
        children: [
          CapsuleButton(
            svgAsset: 'assets/images/homebar_capsule.svg',
            selected: selectedIdx == 0,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 0 ? -1 : 0),
            notificationText: selectedIdx == 0 ? '23분 뒤, 이부프로펜 1알 섭취 예정' : '',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_med.svg',
            selected: selectedIdx == 1,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 1 ? -1 : 1),
            notificationText: selectedIdx == 1 ? '오늘의 통증 부위: 허리, 오른쪽 무릎' : '',
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            svgAsset: 'assets/images/homebar_walk.svg',
            selected: selectedIdx == 2,
            onTap: () =>
                setState(() => selectedIdx = selectedIdx == 2 ? -1 : 2),
            notificationText: selectedIdx == 2 ? '12,000 걸음' : '',
          ),
        ],
      ),
    );
  }
}
