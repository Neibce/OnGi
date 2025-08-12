import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/core/app_colors.dart';
import 'add_pill_screen.dart';

class PillHistoryScreen extends StatefulWidget {
  const PillHistoryScreen({super.key});

  @override
  State<PillHistoryScreen> createState() => _PillHistoryScreenState();
}

class _PillHistoryScreenState extends State<PillHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todaySchedule = <Map<String, dynamic>>[];
  final Set<String> _takenKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _fetchTodaySchedule();
  }

  Future<void> _fetchTodaySchedule() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Map<String, dynamic>> schedule =
          await PillService.getTodayPillSchedule();
      setState(() {
        _todaySchedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _todaySchedule = <Map<String, dynamic>>[];
        _isLoading = false;
      });
    }
  }

  String _displayTime(String raw) {
    if (raw.length >= 5) {
      return raw.substring(0, 5);
    }
    return raw;
  }

  String _mapIntakeDetailToKorean(String label) {
    switch (label) {
      case 'BEFORE_MEAL_30MIN':
        return '식전 30분';
      case 'AFTER_MEAL_30MIN':
        return '식후 30분 이내';
      case 'AFTER_MEAL_60MIN':
        return '식후 1시간';
      case 'BEFORE_SLEEP':
        return '취침 전';
      case 'ANYTIME':
        return '상관없음';
      default:
        return '';
    }
  }

  Future<void> _addRecord({
    required String pillId,
    required String intakeTime,
  }) async {
    try {
      await PillService.addPillRecord(
        pillId: pillId,
        intakeTime: intakeTime,
        intakeDate: DateTime.now(),
      );
      if (!mounted) return;
      final String key = '$pillId|$intakeTime';
      setState(() {
        _takenKeys.add(key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '복용 기록이 추가되었습니다.',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복용 기록 추가 실패: $e',
            style: const TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                        padding: EdgeInsets.only(top: circleSize * 0.815),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                '오늘 복용해야 할 약,',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '다 섭취 하셨나요?',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/images/pill_history_title_logo.png',
                                width: circleSize * 0.26,
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
              top: circleSize * 0.3 + 40,
              left: 0,
              right: 0,
              bottom: 0,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchTodaySchedule,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        itemCount: _todaySchedule.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _todaySchedule.length) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddPillScreen(),
                                  ),
                                ).then((_) {
                                  _fetchTodaySchedule();
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.pillsAddItemBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppColors.pillsAddItemBackgroundDark,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: SvgPicture.asset(
                                        'assets/images/add_icon.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final Map<String, dynamic> pill =
                              _todaySchedule[index];
                          final dynamic idRaw =
                              pill['id'] ?? pill['pillId'] ?? pill['pillID'];
                          final String pillId = idRaw?.toString() ?? '';
                          final String pillName = (pill['name'] ?? '약물')
                              .toString();
                          final String intakeDetail = _mapIntakeDetailToKorean(
                            pill['intakeDetail'],
                          ).toString();
                          // (pill['intakeDetail'] ?? '').toString();
                          final List<dynamic> timesDyn =
                              pill['intakeTimes'] as List<dynamic>? ??
                              <dynamic>[];
                          final List<String> times = timesDyn
                              .map((e) => e.toString())
                              .toList();
                          final int timesCount = times.length;

                          // 카드
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.pillsItemBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/pill_item_icon.svg',
                                  width: 38,
                                  height: 38,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                pillName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '매일, ${timesCount}회${intakeDetail.isNotEmpty ? ', $intakeDetail' : ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: times.map((timeStr) {
                                          final String key = '$pillId|$timeStr';
                                          final bool taken = _takenKeys
                                              .contains(key);
                                          return GestureDetector(
                                            onTap: taken || pillId.isEmpty
                                                ? null
                                                : () => _addRecord(
                                                    pillId: pillId,
                                                    intakeTime: timeStr,
                                                  ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 27,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: taken
                                                    ? Colors.white
                                                    : AppColors.ongiOrange,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _displayTime(timeStr),
                                                    style: TextStyle(
                                                      color: taken
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
