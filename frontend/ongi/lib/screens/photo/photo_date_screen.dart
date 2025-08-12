import 'package:flutter/material.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/core/app_colors.dart';
import 'dart:ui'; // Added for ImageFilter
import 'package:ongi/services/maumlog_service.dart';
import 'package:ongi/models/maumlog.dart';
import 'package:ongi/utils/prefs_manager.dart';

class PhotoDateScreen extends StatefulWidget {
  const PhotoDateScreen({super.key});

  @override
  State<PhotoDateScreen> createState() => _PhotoDateScreenState();
}

class _PhotoDateScreenState extends State<PhotoDateScreen> {
  int _currentPage = 0;
  late Future<List<Emotion>> _emotionsFuture;
  late Future<List<MaumLogRecord>> _maumLogsFuture;
  static const String _apiBaseUrl = 'http://localhost:8080';
  String? _currentUserUuid;

  @override
  void initState() {
    super.initState();
    _emotionsFuture = MaumlogService(baseUrl: _apiBaseUrl).fetchEmotions();
    _maumLogsFuture = MaumlogService(baseUrl: _apiBaseUrl).fetchMaumLogs();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userInfo = await PrefsManager.getUserInfo();
      setState(() {
        _currentUserUuid = userInfo['uuid'];
      });
    } catch (e) {
      print('사용자 정보 로드 실패: $e');
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
        child: FutureBuilder<List<Emotion>>(
          future: _emotionsFuture,
          builder: (context, emotionSnapshot) {
            Map<String, String> codeToDescription = {};
            if (emotionSnapshot.hasData) {
              codeToDescription = {
                for (var e in emotionSnapshot.data!) e.code: e.description
              };
            }
            return Column(
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
                        // 사진 카드 PageView (실제 데이터)
                        Center(
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: FutureBuilder<List<MaumLogRecord>>(
                              future: _maumLogsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(child: Text('불러오기 실패:  [snapshot.error]', style: TextStyle(color: Colors.red)));
                                }
                                final maumLogs = snapshot.data ?? [];
                                
                                // 현재 사용자가 업로드한 사진이 있는지 확인
                                final hasUserUploadedPhoto = _currentUserUuid != null && 
                                    maumLogs.any((log) => log.uploaderUuid == _currentUserUuid);
                                
                                if (maumLogs.isEmpty) {
                                  // 아무도 사진을 업로드하지 않은 경우
                                  return _buildEmptyCard(cardWidth, cardHeight, '아직 기록이 없습니다.');
                                }
                                
                                // 현재 사용자가 사진을 업로드하지 않았지만 다른 사람의 사진이 있는 경우
                                if (!hasUserUploadedPhoto && maumLogs.isNotEmpty) {
                                  // 빈 카드를 먼저 보여주고, 다른 사람들의 사진은 모자이크 처리해서 추가
                                  final allItems = <Widget>[
                                    _buildEmptyCardForPageView(cardWidth, cardHeight, '마음기록을 업로드 해볼까요?'),
                                    ...maumLogs.map((log) => _buildBlurredPhotoCard(log, cardWidth, cardHeight, codeToDescription)),
                                  ];
                                  
                                  return PageView.builder(
                                    itemCount: allItems.length,
                                    controller: PageController(
                                      viewportFraction: 0.78,
                                      initialPage: _currentPage,
                                    ),
                                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                                    itemBuilder: (context, idx) => allItems[idx],
                                  );
                                }
                                
                                return PageView.builder(
                                  itemCount: maumLogs.length,
                                  controller: PageController(
                                    viewportFraction: 0.78,
                                    initialPage: _currentPage,
                                  ),
                                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                                  itemBuilder: (context, idx) {
                                    final log = maumLogs[idx];
                                    final isActive = idx == _currentPage;
                                    // S3 이미지 URL 예시 (실제 경로에 맞게 수정 필요)
                                    final imageUrl = 'https://YOUR_S3_BUCKET_URL/maum-log-photos/${log.fileName}';
                                    
                                    // 모자이크 처리 조건: 현재 사용자가 사진을 업로드하지 않았고, 이 사진이 다른 사람의 것일 때
                                    final shouldBlur = !hasUserUploadedPhoto && 
                                        log.uploaderUuid != _currentUserUuid;
                                    
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
                                            child: shouldBlur
                                                ? ImageFiltered(
                                                    imageFilter: ImageFilter.blur(
                                                      sigmaX: 8,
                                                      sigmaY: 8,
                                                    ),
                                                    child: Opacity(
                                                      opacity: 0.7,
                                                      child: Image.network(
                                                        imageUrl,
                                                        width: cardWidth,
                                                        height: cardHeight,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                : Image.network(
                                                    imageUrl,
                                                    width: cardWidth,
                                                    height: cardHeight,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          // 좌상단 서브(프로필) 사진 (없으면 생략)
                                          // ... 필요시 추가 ...
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
                                                  // 감정 태그
                                                  Wrap(
                                                    spacing: 8,
                                                    children: log.emotions.map((code) => _buildTagButton(
                                                      codeToDescription[code] ?? code,
                                                      AppColors.ongiOrange,
                                                    )).toList(),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // 코멘트
                                                  Text(
                                                    log.comment ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
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
                                                  const SizedBox(height: 8),
                                                  // 위치
                                                  if (log.location != null && log.location!.isNotEmpty)
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(20),
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
                                                              log.location!,
                                                              style: const TextStyle(
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
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 페이지인디케이터 (실제 데이터 기반)
                        FutureBuilder<List<MaumLogRecord>>(
                          future: _maumLogsFuture,
                          builder: (context, snapshot) {
                            final maumLogs = snapshot.data ?? [];
                            final hasUserUploadedPhoto = _currentUserUuid != null && 
                                maumLogs.any((log) => log.uploaderUuid == _currentUserUuid);
                            
                            int count = maumLogs.length;
                            if (!hasUserUploadedPhoto && maumLogs.isNotEmpty) {
                              count = maumLogs.length + 1; // 빈 카드도 포함
                            }
                            
                            if (count == 0) return const SizedBox.shrink();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < count; i++) ...[
                                  _buildIndicator(i == _currentPage),
                                  if (i != count - 1) const SizedBox(width: 6),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        style: const TextStyle(
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

  Widget _buildEmptyCard(double cardWidth, double cardHeight, String message) {
    return Center(
      child: Container(
        width: cardWidth * 0.78,
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppColors.ongiOrange,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '사진을 업로드하고\n가족들의 사진을 확인해보세요!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCardForPageView(double cardWidth, double cardHeight, String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.ongiOrange,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '사진을 업로드하고\n가족들의 사진을 확인해보세요!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredPhotoCard(MaumLogRecord log, double cardWidth, double cardHeight, Map<String, String> codeToDescription) {
    final imageUrl = 'https://YOUR_S3_BUCKET_URL/maum-log-photos/${log.fileName}';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Opacity(
                opacity: 0.7,
                child: Image.network(
                  imageUrl,
                  width: cardWidth,
                  height: cardHeight,
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
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 감정 태그
                  Wrap(
                    spacing: 8,
                    children: log.emotions.map((code) => _buildTagButton(
                      codeToDescription[code] ?? code,
                      AppColors.ongiOrange,
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 코멘트
                  Text(
                    log.comment ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                  const SizedBox(height: 8),
                  // 위치
                  if (log.location != null && log.location!.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                              log.location!,
                              style: const TextStyle(
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
  }
}
