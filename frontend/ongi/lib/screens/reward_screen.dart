import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/temperature_service.dart';
import 'package:ongi/widgets/reward_product_card.dart';
import 'package:ongi/utils/prefs_manager.dart';

class RewardScreen extends StatefulWidget {
  final VoidCallback? onRewardTap;
  const RewardScreen({super.key, this.onRewardTap});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  double? availableTempValue;
  final items = [
    Product(
      "20°C",
      "[스타벅스] 아이스 카페 아메리카노 T",
      "assets/images/reward_products/americano.png",
    ),
    Product(
      "40°C",
      "[동아제약] 박카스F (120ml X 10병)",
      "assets/images/reward_products/bacchus.png",
    ),
    Product(
      "80°C",
      "[교촌] 허니콤보 + 콜라 1.25L",
      "assets/images/reward_products/honeycombo.png",
    ),
    Product(
      "120°C",
      "[정관장] 활기력 (20ml x 10병)",
      "assets/images/reward_products/jeonggwanjang.png",
    ),
    Product(
      "160°C",
      "[오쏘몰] 멀티비타민&미네랄 10입",
      "assets/images/reward_products/orthomol.png",
    ),
    Product(
      "200°C",
      "[농협안심한우] 한우구이세트 500g",
      "assets/images/reward_products/beef.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTempValue();
  }

  void _handleBack() async {
    if (widget.onRewardTap != null) {
      widget.onRewardTap!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _loadTempValue() async {
    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      if (familyCode == null) throw Exception('가족 코드가 없습니다.');
      final token = await PrefsManager.getAccessToken();
      final service = TemperatureService(
        baseUrl: 'https://ongi-1049536928483.asia-northeast3.run.app',
      );
      final dailyTemps = await service.fetchFamilyTemperatureDaily(
        familyCode,
        token: token,
      );
      final today = DateTime.now();
      final todayStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final match = dailyTemps.firstWhere(
        (e) => e['date'] == todayStr,
        orElse: () => <String, dynamic>{},
      );
      setState(() {
        availableTempValue = match.isEmpty
            ? 0.0
            : ((match['totalTemperature'] as num?)?.toDouble() ?? 36.5);
      });
    } catch (e) {
      setState(() {
        availableTempValue = 36.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
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
                          padding: EdgeInsets.only(top: circleSize * 0.66),
                          child: OverflowBox(
                            maxHeight: double.infinity,
                            child: Column(
                              children: [
                                const Text(
                                  '우리가족의 온기를 모아,',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                ),
                                const Text(
                                  '따뜻한 혜택으로',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
              Positioned.fill(
                top: circleSize * 0.35,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 55),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '모은 우리가족의 온도 지수로\n따뜻한 선물을 교환해보세요!',
                                    style: TextStyle(
                                      color: Colors.black,
                                      height: 1.2,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Neumorphic(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.fromLTRB(
                                        15,
                                        18,
                                        15,
                                        10,
                                      ),
                                      style: NeumorphicStyle(
                                        color: Colors.white,
                                        depth: -5, // +면 돌출, -면 들어간 효과
                                        intensity: 0.3,
                                        shadowDarkColorEmboss: Colors.black54
                                            .withOpacity(0.9),
                                        shape: NeumorphicShape.concave,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(20),
                                        ),
                                        border: NeumorphicBorder(
                                          color: AppColors.ongiGrey,
                                          width: 0.1,
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 90,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/images/all_pfp_icons.png',
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '우리가족이',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.2,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const Text(
                                                    '사용 가능한 온도',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.1,
                                                      color:
                                                          AppColors.ongiOrange,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Text(
                                                      availableTempValue != null
                                                          ? '${availableTempValue!.toStringAsFixed(1)}°C'
                                                          : '--.-°C',
                                                      textHeightBehavior:
                                                          TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                      style: const TextStyle(
                                                        fontSize: 47,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        height: 1.0,
                                                        color: AppColors
                                                            .ongiOrange,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.ongiOrange,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(12, 20, 10, 0),
                                  child: Image.asset(
                                    'assets/images/photobook_icon.png',
                                    width: 110,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          '온기와 함께한',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Text(
                                          '모든 시간이 담긴',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            height: 0.8,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          '가족 포토앨범',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
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
                            top: -15,
                            left: 25,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ongiOrange,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                '300°C 달성!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: const Text(
                          '해당 상품을 구매 시, 우리가족 온도 지수가 차감돼요!',
                          style: TextStyle(
                            color: Colors.black,
                            height: 1.2,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GridView.builder(
                        padding: const EdgeInsets.all(2),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                              mainAxisExtent: 180,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return RewardProductCard(item: items[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: circleSize * 0.19,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Image.asset(
                      'assets/images/reward_gift_icon.png',
                      width: circleSize * 0.24,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 20,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/back_icon_white.svg',
                    height: 35,
                    width: 35,
                  ),
                  onPressed: _handleBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
