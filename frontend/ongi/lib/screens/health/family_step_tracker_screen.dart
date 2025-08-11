import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/widgets/date_carousel.dart';
import 'package:ongi/services/step_service.dart';

class FamilyStepTrackerScreen extends StatefulWidget {
  const FamilyStepTrackerScreen({super.key});

  @override
  State<FamilyStepTrackerScreen> createState() =>
      _FamilyStepTrackerScreenState();
}

class _FamilyStepTrackerScreenState extends State<FamilyStepTrackerScreen> {
  Map<int, int> selectedDosages = {};
  late final PageController _dateCarouselController;
  DateTime selectedDate = DateTime.now();
  final StepService _stepService = StepService();
  bool _isLoading = false;
  int _totalSteps = 0;
  String? _errorMessage;
  List<_MemberStep> _memberSteps = [];

  @override
  void initState() {
    super.initState();
    _dateCarouselController = PageController(initialPage: 5000);
    _fetchStepsForDate(selectedDate);
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
        _errorMessage = '걸음 수 조회 실패';
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
                                '오늘 걸은 만큼 건강도 쌓였습니다.',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                '잘하셨어요!',
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
                                  'assets/images/step_tracker_title_logo.png',
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
            Positioned(
              top: circleSize * 0.4,
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 15,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // 본문 내용
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '오늘 우리 가족은',
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
                                          text: '총 ',
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
                                              : _totalSteps
                                                        .toString()
                                                        .replaceAllMapped(
                                                          RegExp(
                                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                          ),
                                                          (m) => '${m[1]},',
                                                        ) +
                                                    '걸음',
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 85,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: DateCarousel(
                                        initialDate: selectedDate,
                                        controller: _dateCarouselController,
                                        onDateChanged: _updateFromDateCarousel,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                                    _buildStepMember(
                                      context: context,
                                      name: _memberSteps[i].userName,
                                      steps: _memberSteps[i].steps,
                                      image: _memberSteps[i].imageAsset,
                                      isTop:
                                          i == 0 && _memberSteps[i].steps > 0,
                                    ),
                                  if (_memberSteps.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text('가족 걸음 데이터가 없습니다.'),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

Widget _buildStepMember({
  required BuildContext context,
  required String name,
  required int steps,
  required String image,
  bool isTop = false,
}) {
  return Container(
    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 프로필 이미지 (pill 왼쪽)
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: 70, height: 80, child: Image.asset(image)),
            if (isTop)
              Positioned(
                left: -12,
                top: -15,
                child: SizedBox(
                  width: 42,
                  height: 32,
                  child: SvgPicture.asset(
                    'assets/images/step_tracker_crown.svg',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFD6C01),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Spacer(),
                    Text(
                      steps.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 40,
                        height: 0.7,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '걸음',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
