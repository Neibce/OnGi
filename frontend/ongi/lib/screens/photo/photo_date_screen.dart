import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/models/maum_log.dart';
import 'package:ongi/services/maum_log_service.dart';
import 'dart:ui'; // Added for ImageFilter

class PhotoDateScreen extends StatefulWidget {
  final String date;

  const PhotoDateScreen({super.key, required this.date});

  @override
  State<PhotoDateScreen> createState() => _PhotoDateScreenState();
}

class _PhotoDateScreenState extends State<PhotoDateScreen> {
  int _currentPage = 0;
  MaumLogResponse? _maumLogResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMaumLogData();
  }

  @override
  void didUpdateWidget(PhotoDateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadMaumLogData();
    }
  }

  Future<void> _loadMaumLogData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await MaumLogService.getMaumLog(widget.date);

      setState(() {
        _maumLogResponse = response;
        _isLoading = false;
        if (response.maumLogDtos.isNotEmpty) {
          _currentPage = 0;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth;
    final cardHeight = screenHeight * 0.4;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 130),
                // 타이틀
                const Text(
                  '우리가족의',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                ),
                const Text(
                  '마음 기록',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.ongiOrange,
                  ),
                ),
                const SizedBox(height: 45),
                // 사진 카드 PageView
                Center(
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildContent(cardWidth, cardHeight),
                  ),
                ),
                const SizedBox(height: 16),
                // 감정 태그 버튼
                _buildEmotionTags(),
                const SizedBox(height: 16),
                // 페이지인디케이터
                _buildPageIndicators(),
                const SizedBox(height: 40), // 하단 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double cardWidth, double cardHeight) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.ongiOrange,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.ongiOrange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '마음 기록을 불러올 수 없습니다',
              style: TextStyle(
                color: AppColors.ongiOrange,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMaumLogData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ongiOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_maumLogResponse == null || _maumLogResponse!.maumLogDtos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              color: AppColors.ongiOrange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              '이 날의 마음 기록이 없습니다',
              style: TextStyle(
                color: AppColors.ongiOrange,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final maumLogs = _maumLogResponse!.maumLogDtos;

    return PageView.builder(
      itemCount: maumLogs.length,
      controller: PageController(
        viewportFraction: 0.78,
        initialPage: _currentPage,
      ),
      onPageChanged: (idx) => setState(() => _currentPage = idx),
      itemBuilder: (context, idx) {
        final maumLog = maumLogs[idx];
        final isActive = idx == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: isActive ? 0 : 8,
            vertical: isActive ? 0 : 16,
          ),
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: isActive
                    ? Image.network(
                  maumLog.frontPresignedUrl,
                  width: cardWidth,
                  height: cardHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: cardWidth,
                      height: cardHeight,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    );
                  },
                )
                    : ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 8,
                    sigmaY: 8,
                  ),
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.network(
                      maumLog.frontPresignedUrl,
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: cardWidth,
                          height: cardHeight,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // 좌상단 서브(프로필) 사진
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  width: 88,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.ongiOrange,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      maumLog.backPresignedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // 하단 오버레이
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/images/users/elderly_woman.png", width: 30),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              maumLog.comment,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 위치 버튼 스타일
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/images/location_icon.svg'),
                              const SizedBox(width: 4),
                              Text(
                                maumLog.location,
                                style: TextStyle(
                                  color: AppColors.ongiOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
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
        );
      },
    );
  }

  Widget _buildEmotionTags() {
    if (_maumLogResponse == null ||
        _maumLogResponse!.maumLogDtos.isEmpty ||
        _currentPage >= _maumLogResponse!.maumLogDtos.length) {
      return const SizedBox.shrink();
    }

    final currentMaumLog = _maumLogResponse!.maumLogDtos[_currentPage];
    final emotions = currentMaumLog.formattedEmotions;

    if (emotions.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> rows = [];
    for (int i = 0; i < emotions.length; i += 4) {
      final rowEmotions = emotions.sublist(i, i + 4 > emotions.length ? emotions.length : i + 4);
      
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int j = 0; j < rowEmotions.length; j++) ...[
              _buildTagButton(rowEmotions[j], AppColors.ongiOrange),
              if (j != rowEmotions.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      );
      
      // 마지막 행이 아니면 세로 간격 추가
      if (i + 4 < emotions.length) {
        rows.add(const SizedBox(height: 2));
      }
    }

    return Column(
      children: rows,
    );
  }

  Widget _buildPageIndicators() {
    if (_maumLogResponse == null || _maumLogResponse!.maumLogDtos.isEmpty) {
      return const SizedBox.shrink();
    }

    final maumLogs = _maumLogResponse!.maumLogDtos;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < maumLogs.length; i++) ...[
          _buildIndicator(i == _currentPage),
          if (i != maumLogs.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildTagButton(String text, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.ongiOrange,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: isActive ? 15 : 10,
      height: isActive ? 15 : 10,
      decoration: BoxDecoration(
        color: isActive ? AppColors.ongiOrange : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}