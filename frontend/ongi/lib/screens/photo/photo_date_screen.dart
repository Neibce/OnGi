import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'dart:ui'; // Added for ImageFilter

class PhotoDateScreen extends StatefulWidget {
  const PhotoDateScreen({super.key});

  @override
  State<PhotoDateScreen> createState() => _PhotoDateScreenState();
}

class _PhotoDateScreenState extends State<PhotoDateScreen> {
  int _currentPage = 1;
  final List<Map<String, String>> _photos = [
    {
      'main': 'assets/images/sample_family_photo.png',
      'sub': 'assets/images/sample_family_photo.png',
      'profile': 'assets/images/users/elderly_woman.png',
      'text': '엄마는 금정산 등산 덕에 활기가 너무 좋다~',
      'location': '부산광역시, 장전동',
    },
    {
      'main': 'assets/images/sample_family_photo.png',
      'sub': 'assets/images/sample_family_photo.png',
      'profile': 'assets/images/users/elderly_woman.png',
      'text': '오늘은 가족과 함께 산책 헤헤',
      'location': '서울특별시, 강남구',
    },
    {
      'main': 'assets/images/sample_family_photo.png',
      'sub': 'assets/images/sample_family_photo.png',
      'profile': 'assets/images/users/elderly_woman.png',
      'text': '즐거운 여행의 추억 :)',
      'location': '경기도, 수원시',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth;
    final cardHeight = screenHeight * 0.4;
    // 카드 크기 되돌림
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLightBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        child: PageView.builder(
                          itemCount: _photos.length,
                          controller: PageController(
                            viewportFraction: 0.78,
                            initialPage: _currentPage,
                          ),
                          onPageChanged: (idx) =>
                              setState(() => _currentPage = idx),
                          itemBuilder: (context, idx) {
                            final photo = _photos[idx];
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
                                        ? Image.asset(
                                            photo['main']!,
                                            width: cardWidth,
                                            height: cardHeight,
                                            fit: BoxFit.cover,
                                          )
                                        : ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: 8,
                                              sigmaY: 8,
                                            ),
                                            child: Opacity(
                                              opacity: 0.7,
                                              child: Image.asset(
                                                photo['main']!,
                                                width: cardWidth,
                                                height: cardHeight,
                                                fit: BoxFit.cover,
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
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          photo['sub'] ?? photo['main']!,
                                          fit: BoxFit.cover,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              // 원형 프로필
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: AssetImage(
                                                  photo['profile']!,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  photo['text']!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black38,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.place,
                                                    color: AppColors.ongiOrange,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    photo['location']!,
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.ongiOrange,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                        ),
                      ),
                    ),
                    // 감정 태그 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTagButton('뿌듯함', AppColors.ongiOrange),
                        const SizedBox(width: 6),
                        _buildTagButton('기운이 남', AppColors.ongiOrange),
                        const SizedBox(width: 6),
                        _buildTagButton('들뜸', AppColors.ongiOrange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 페이지인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _photos.length; i++) ...[
                          _buildIndicator(i == _currentPage),
                          if (i != _photos.length - 1) const SizedBox(width: 6),
                        ],
                      ],
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
