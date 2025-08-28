import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/models/maum_log.dart';
import 'package:ongi/services/maum_log_service.dart';
import 'package:ongi/services/family_service.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'dart:ui';

import '../add_record_screen.dart'; // Added for ImageFilter

class PhotoDateScreen extends StatefulWidget {
  final String date;

  const PhotoDateScreen({super.key, required this.date});

  @override
  State<PhotoDateScreen> createState() => _PhotoDateScreenState();
}

class _PhotoDateScreenState extends State<PhotoDateScreen> {
  int _currentPage = 0;
  MaumLogResponse? _maumLogResponse;
  List<Map<String, dynamic>> _familyMembers = [];
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

      // 마음 기록과 가족 구성원 정보를 동시에 로드
      final futures = [
        MaumLogService.getMaumLog(widget.date),
        FamilyService.getFamilyMembers(),
      ];

      final results = await Future.wait(futures);
      final response = results[0] as MaumLogResponse;
      final familyMembers = results[1] as List<Map<String, dynamic>>;

      setState(() {
        _maumLogResponse = response;
        _familyMembers = familyMembers;
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
    final contentWidth = screenWidth - 80; // 좌우 패딩 40씩 고려
    const viewport = 0.90; // 카드 크기 증가
    final cardWidth = contentWidth * viewport; // 실제 카드 폭
    final cardHeight = cardWidth * 1.2; // 마음기록 추가 화면(1:1.2)과 동일 비율

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
                    width: contentWidth,
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
        child: CircularProgressIndicator(color: AppColors.ongiOrange),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ongiOrange,
                fixedSize: const Size(270, 310),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRecordScreen()),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '마음기록을',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 36,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '업로드\n해볼까요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
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
        viewportFraction: 0.90,
        initialPage: _currentPage,
      ),
      onPageChanged: (idx) => setState(() => _currentPage = idx),
      itemBuilder: (context, idx) {
        final maumLog = maumLogs[idx];
        final isActive = idx == _currentPage;
        final hasUploadedOwn = _maumLogResponse!.hasUploadedOwn;
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
                child: (isActive && hasUploadedOwn)
                    ? Image.network(
                        maumLog.backPresignedUrl,
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
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          // 선명한 이미지 (상단)
                          Image.network(
                            maumLog.backPresignedUrl,
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
                          // 블러 이미지 (그라데이션 마스크)
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.white,
                                  Colors.white,
                                ],
                                stops: [0.0, 0.2, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: OverflowBox(
                              maxWidth: cardWidth + 60,
                              maxHeight: cardHeight + 60,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 30,
                                  sigmaY: 30,
                                ),
                                child: Image.network(
                                  maumLog.backPresignedUrl,
                                  width: cardWidth + 60,
                                  height: cardHeight + 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: cardWidth + 60,
                                      height: cardHeight + 60,
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
                        ],
                      ),
              ),
              // 좌상단 서브(프로필) 사진 - 항상 표시, hasUploadedOwn이 false면 블러 처리
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  width: 88,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ongiOrange, width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasUploadedOwn
                        ? Image.network(
                            maumLog.frontPresignedUrl,
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
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              // 선명한 이미지 (상단)
                              Image.network(
                                maumLog.frontPresignedUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
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
                              // 블러 이미지 (그라데이션 마스크)
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white,
                                      Colors.white,
                                    ],
                                    stops: [0.0, 0.2, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: OverflowBox(
                                  maxWidth: 88 + 40,
                                  maxHeight: 100 + 40,
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 25,
                                      sigmaY: 25,
                                    ),
                                    child: Image.network(
                                      maumLog.frontPresignedUrl,
                                      width: 88 + 40,
                                      height: 100 + 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 88 + 40,
                                              height: 100 + 40,
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
                            ],
                          ),
                  ),
                ),
              ),
              // 하단 오버레이 - hasUploadedOwn이 true일 때만 표시
              if (hasUploadedOwn)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FutureBuilder<String>(
                                      future:
                                          PrefsManager.getProfileImagePathByUserName(
                                            maumLog.uploader.name,
                                            _familyMembers,
                                          ),
                                      builder: (context, snapshot) {
                                        final profileImagePath =
                                            snapshot.data ??
                                            PrefsManager.getProfileImagePath(0);
                                        return Image.asset(
                                          profileImagePath,
                                          width: 30,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      maumLog.comment ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    maumLog.uploader.name,
                                    style: const TextStyle(
                                      color: AppColors.ongiOrange,
                                      fontSize: 8,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 위치 정보가 유효한 경우에만 표시
                        if (maumLog.location.isNotEmpty &&
                            maumLog.location != "위치 정보를 불러올 수 없습니다.")
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
                                  SvgPicture.asset(
                                    'assets/images/location_icon.svg',
                                  ),
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
      final rowEmotions = emotions.sublist(
        i,
        i + 4 > emotions.length ? emotions.length : i + 4,
      );

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

    return Column(children: rows);
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
