import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/widgets/custom_drop_down.dart';
import 'package:ongi/screens/health/pill_update_popup.dart';
import 'package:ongi/services/pill_service.dart';
import 'package:ongi/utils/prefs_manager.dart';

class AddPillScreen extends StatefulWidget {
  final String? targetParentId;
  
  const AddPillScreen({
    super.key,
    this.targetParentId,
  });

  @override
  State<AddPillScreen> createState() => _AddPillScreenState();
}

class _AddPillScreenState extends State<AddPillScreen> {
  final TextEditingController _nameController = TextEditingController();
  Set<String> selectedDays = <String>{};
  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
  String selectedFrequency = '하루 세 번';
  final List<String> frequencies = ['하루 한 번', '하루 두 번', '하루 세 번', '하루 네 번'];
  String selectedTime = '08:00';
  final List<String> times = [
    '00:00',
    '00:30',
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];
  List<String> selectedTimes = ['08:30'];
  String selectedMealTiming = '식후 30분 이내';
  final List<String> mealTimings = [
    '식전 30분',
    '식후 30분 이내',
    '식후 1시간',
    '취침 전',
    '상관없음',
  ];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _frequencyToTimes(String frequency) {
    switch (frequency) {
      case '하루 한 번':
        return 1;
      case '하루 두 번':
        return 2;
      case '하루 세 번':
        return 3;
      case '하루 네 번':
        return 4;
      default:
        return 1;
    }
  }

  List<String> _mapDaysToServer(Set<String> daysKo) {
    const Map<String, String> koToEnum = {
      '월': 'MONDAY',
      '화': 'TUESDAY',
      '수': 'WEDNESDAY',
      '목': 'THURSDAY',
      '금': 'FRIDAY',
      '토': 'SATURDAY',
      '일': 'SUNDAY',
    };
    // 선택 순서 유지
    final List<String> ordered = days
        .where((d) => daysKo.contains(d))
        .map((d) => koToEnum[d] ?? d)
        .toList();
    return ordered;
  }

  String _mapIntakeDetailToServer(String label) {
    switch (label) {
      case '식전 30분':
        return 'BEFORE_MEAL_30MIN';
      case '식후 30분 이내':
        return 'AFTER_MEAL_30MIN';
      case '식후 1시간':
        return 'AFTER_MEAL_60MIN';
      case '취침 전':
        return 'BEFORE_SLEEP';
      case '상관없음':
        return 'ANYTIME';
      default:
        return 'ANYTIME';
    }
  }

  Future<void> _submit() async {
    final String pillName = _nameController.text.trim();
    if (pillName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '약 이름을 입력해주세요.',
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
      return;
    }

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '복용 요일을 하나 이상 선택해주세요.',
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
      return;
    }

    final int timesPerDay = _frequencyToTimes(selectedFrequency);
    if (selectedTimes.length < timesPerDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복용 시간을 ${timesPerDay}개 선택해주세요.',
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
      return;
    }

    // 전달받은 targetParentId가 있으면 사용, 없으면 본인 UUID 사용
    String? parentUuid = widget.targetParentId;
    if (parentUuid == null) {
      parentUuid = await PrefsManager.getUuid();
    }
    
    if (parentUuid == null || parentUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'uuid가 존재하지 않습니다. 재로그인 후 다시 시도해주세요.',
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
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await PillService.addPills(
        name: pillName,
        times: timesPerDay,
        intakeDetail: _mapIntakeDetailToServer(selectedMealTiming),
        intakeTimes: selectedTimes.take(timesPerDay).toList(),
        intakeDays: _mapDaysToServer(selectedDays),
        parentUuid: parentUuid,
      );

      if (!mounted) return;
      
      // 즉시 홈으로 돌아가면서 성공 결과 전달
      Navigator.pop(context, true);
      
      // 성공 팝업을 약간 지연 후 표시 (홈 화면이 먼저 업데이트되도록)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => Dialog(
            backgroundColor: Colors.transparent,
            child: const PillUpdatePopup(),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('약 정보 등록에 실패했습니다: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 150),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          top: 10,
                        ),
                        child: TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontSize: 25,
                            color: AppColors.ongiOrange,
                          ),
                          decoration: InputDecoration(
                            hintText: '약 이름',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 13,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.ongiOrange,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.ongiOrange,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '약 복용 일정',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  final isSelected = selectedDays.contains(day);
                                  final isLastItem = index == days.length - 1;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: isLastItem ? 40 : 12,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedDays.remove(day);
                                          } else {
                                            selectedDays.add(day);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.ongiOrange
                                              : Colors.white,
                                          border: Border.all(
                                            color: AppColors.ongiOrange,
                                            width: 1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            day,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.ongiOrange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: CustomDropdown(
                          value: selectedFrequency,
                          items: frequencies,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFrequency = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: CustomDropdown(
                          value: selectedTime,
                          items: times,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTime = newValue!;
                              if (!selectedTimes.contains(newValue)) {
                                selectedTimes.add(newValue);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedTimes.length,
                            itemBuilder: (context, index) {
                              final time = selectedTimes[index];
                              final isLastItem =
                                  index == selectedTimes.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: isLastItem ? 40 : 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.ongiOrange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 30,
                                          right: 8,
                                        ),
                                        child: Text(
                                          time,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTimes.remove(time);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: CustomDropdown(
                          value: selectedMealTiming,
                          items: mealTimings,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMealTiming = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 40,
                  top: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ongiOrange,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '등록하기',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            right: 30,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/close_icon_black.svg',
                width: 28,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              iconSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}
