import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/services/step_service.dart';
import 'package:ongi/utils/prefs_manager.dart';

class CrossFamilyRankingScreen extends StatefulWidget {
  const CrossFamilyRankingScreen({super.key});

  @override
  State<CrossFamilyRankingScreen> createState() =>
      _CrossFamilyRankingScreenState();
}

class _CrossFamilyRankingScreenState extends State<CrossFamilyRankingScreen> {
  Map<int, int> selectedDosages = {};
  late final PageController _dateCarouselController;
  DateTime selectedDate = DateTime.now();
  final StepService _stepService = StepService();
  bool _isLoading = false;
  int _totalSteps = 0;
  String? _errorMessage;
  List<_MemberStep> _memberSteps = [];
  String? _currentUserId;


  @override
  void initState() {
    super.initState();
    _dateCarouselController = PageController(initialPage: 5000);
    _loadCurrentUserId();
    _fetchStepsForDate(selectedDate);
  }

  Future<void> _loadCurrentUserId() async {
    String? userId = await PrefsManager.getUuid();
    setState(() {
      _currentUserId = userId;
    });
  }

  @override
  void dispose() {
    _dateCarouselController.dispose();
    super.dispose();
  }

  void _updateFromDateCarousel(DateTime date) {
    setState(() {
      selectedDate = DateTime(date.year, date.month, date.day);
    });
    _fetchStepsForDate(selectedDate);
  }

  String _formatDate(DateTime date) {
    // yyyy-MM-dd
    return date.toIso8601String().split('T').first;
  }

  Future<void> _fetchStepsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String dateStr = _formatDate(date);
      final Map<String, dynamic>? result = await _stepService.getSteps(
        date: dateStr,
      );

      int parsedTotal = 0;
      final List<_MemberStep> parsedMembers = [];
      if (result != null) {
        if (result['totalSteps'] is int) {
          parsedTotal = result['totalSteps'] as int;
        } else if (result['steps'] is int) {
          parsedTotal = result['steps'] as int;
        } else if (result['total'] is int) {
          parsedTotal = result['total'] as int;
        }

        final dynamic members = result['memberSteps'];
        if (members is List) {
          for (final dynamic item in members) {
            if (item is Map<String, dynamic>) {
              final String userId = (item['userId'] ?? '').toString();
              final String userName = (item['userName'] ?? '').toString();
              final int steps = (item['steps'] is int)
                  ? item['steps'] as int
                  : int.tryParse(item['steps']?.toString() ?? '0') ?? 0;
              parsedMembers.add(
                _MemberStep(
                  userId: userId,
                  userName: userName.isEmpty ? '이름없음' : userName,
                  steps: steps,
                  imageAsset: 'assets/images/users/elderly_woman.png',
                ),
              );
            }
          }
        }
      }

      parsedMembers.sort((a, b) => b.steps.compareTo(a.steps));

      setState(() {
        _totalSteps = parsedTotal;
        _memberSteps = parsedMembers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '걸음 수 조회 실패 ';
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
                                : (_memberSteps.isNotEmpty 
                                    ? (_memberSteps.map((e) => e.steps).reduce((a, b) => a + b) ~/ _memberSteps.length)
                                        .toString()
                                        .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]},',
                                    ) + '걸음'
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
                      else if (_isLoading && _memberSteps.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < _memberSteps.length; i++)
                                                                  _buildRankingMember(
                                      context: context,
                                      rank: i + 1,
                                      name: _memberSteps[i].userName,
                                      steps: _memberSteps[i].steps,
                                      isCurrentUser: _memberSteps[i].userId == _currentUserId,
                                    ),
                            if (_memberSteps.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('가족 걸음 데이터가 없습니다.'),
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

class _MemberStep {
  final String userId;
  final String userName;
  final int steps;
  final String imageAsset;

  _MemberStep({
    required this.userId,
    required this.userName,
    required this.steps,
    required this.imageAsset,
  });
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
          offset: const Offset(30, 0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.ongiOrange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isCurrentUser ? null : Border.all(
                color: AppColors.ongiOrange,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Stack(
              children: [
                // 이름
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isCurrentUser ? Colors.white : AppColors.ongiOrange,
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
                        // steps.toString().replaceAllMapped(
                        //   RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        //   (m) => '${m[1]},',
                        // ),
                        '132,335',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: isCurrentUser ? Colors.white : AppColors.ongiOrange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '걸음',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isCurrentUser ? Colors.white : AppColors.ongiOrange,
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
  );
}



