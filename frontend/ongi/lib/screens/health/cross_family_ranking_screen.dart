import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/services/step_rank_service.dart';
import 'package:ongi/utils/prefs_manager.dart';

class CrossFamilyRankingScreen extends StatefulWidget {
  const CrossFamilyRankingScreen({super.key});

  @override
  State<CrossFamilyRankingScreen> createState() =>
      _CrossFamilyRankingScreenState();
}

class _CrossFamilyRankingScreenState extends State<CrossFamilyRankingScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<FamilyStepRank> _familyRanks = [];

  @override
  void initState() {
    super.initState();
    _fetchFamilyRanks();
  }

  Future<void> _fetchFamilyRanks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? accessToken = await PrefsManager.getAccessToken();
      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final List<FamilyStepRank> ranks = await StepRankService.fetchFamilyStepRanks(accessToken);

      setState(() {
        _familyRanks = ranks;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:') 
            ? e.toString().replaceFirst('Exception: ', '')
            : '가족 랭킹 조회 실패';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                        padding: EdgeInsets.only(top: circleSize * 0.86),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                '다른 가족들은',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '얼마나 걸었을까요?',
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
                                  'assets/images/cross_family_ranking_title_logo.png',
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
            // 상단 정보 박스
            Positioned(
              top: circleSize * 0.5,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번주 우리가족은',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        height: 1.2,
                        color: Color(0xFFFD6C01),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '평균 ',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFFFD6C01),
                            ),
                          ),
                          TextSpan(
                            text: _isLoading
                                ? '0걸음'
                                : (_familyRanks.isNotEmpty
                                ? (_familyRanks.firstWhere((rank) => rank.isOurFamily, 
                                    orElse: () => FamilyStepRank(familyName: '', averageSteps: 0, isOurFamily: false)).averageSteps)
                                .toString()
                                .replaceAllMapped(
                              RegExp(
                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                              ),
                                  (m) => '${m[1]},',
                            ) +
                                '걸음'
                                : '0걸음'),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              fontSize: 35,
                              color: Color(0xFFFD6C01),
                            ),
                          ),
                          const TextSpan(
                            text: ' 걸었어요!',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFFFD6C01),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '산정 방식: (1주간 가족 총 걸음 수) ÷ 가족 인원 수',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 하단 랭킹 박스
            Positioned(
              top: circleSize * 0.5 + 140,
              left: 15,
              right: 15,
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else if (_isLoading && _familyRanks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < _familyRanks.length; i++)
                              _buildRankingMember(
                                context: context,
                                rank: i + 1,
                                name: _familyRanks[i].familyName,
                                steps: _familyRanks[i].averageSteps,
                                isCurrentUser: _familyRanks[i].isOurFamily,
                              ),
                            if (_familyRanks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('가족 랭킹 데이터가 없습니다.'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



Widget _buildRankingMember({
  required BuildContext context,
  required int rank,
  required String name,
  required int steps,
  required bool isCurrentUser,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // 메인 컨테이너
        Transform.translate(
          offset: Offset(isCurrentUser ? 20:40, 0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.ongiOrange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isCurrentUser
                  ? null
                  : Border.all(color: AppColors.ongiOrange, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Stack(
              children: [
                //이름
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isCurrentUser
                          ? Colors.white
                          : AppColors.ongiOrange,
                    ),
                  ),
                ),
                //걸음수
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        steps.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},',
                        ),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: isCurrentUser
                              ? Colors.white
                              : AppColors.ongiOrange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '걸음',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isCurrentUser
                              ? Colors.white
                              : AppColors.ongiOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 우리 가족 순위
        if (isCurrentUser)
          Positioned(
            left: -25,
            top: -25,
            child: Container(
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w800,
                    fontSize: 64,
                    color: AppColors.ongiOrange,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}