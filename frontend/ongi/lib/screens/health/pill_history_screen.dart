import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_colors.dart';

class PillHistoryScreen extends StatefulWidget {
  const PillHistoryScreen({super.key});

  @override
  State<PillHistoryScreen> createState() => _PillHistoryScreenState();
}

class _PillHistoryScreenState extends State<PillHistoryScreen> {
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
                offset: Offset(0, -circleSize * 0.82),
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
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: 10,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return GestureDetector(
                      onTap: () {
                        print("ee");
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                        padding: EdgeInsets.all(20),
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
                              color: AppColors.pillsAddItemBackgroundDark,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
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

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    padding: EdgeInsets.all(20),
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
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '고혈압약 - ${index + 1}이부브로펜',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      '매일, 3회, 식후 30분 이내',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  for (int dosage = 1; dosage <= 3; dosage++)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if(selectedDosages[index] == dosage) {
                                                selectedDosages[index] = 0;
                                              }
                                              else {
                                                selectedDosages[index] = dosage;
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  selectedDosages[index] == dosage
                                                  ? Colors.white
                                                  : AppColors.ongiOrange,
                                              borderRadius: BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${dosage}회',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      selectedDosages[index] ==
                                                          dosage
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
