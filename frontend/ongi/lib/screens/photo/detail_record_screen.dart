import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/maumlog_service.dart';
import 'package:ongi/models/maumlog.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/photo/photo_remind_popup.dart';
import 'package:ongi/screens/photo/photo_update_popup.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/maum_log_service.dart';

class DetailRecordScreen extends StatefulWidget {
  final String backImagePath;
  final String? frontImagePath;
  final String? address;
  final DateTime? date;
  const DetailRecordScreen({
    super.key,
    required this.backImagePath,
    this.frontImagePath,
    this.address,
    this.date,
  });

  @override
  State<DetailRecordScreen> createState() => _DetailRecordScreenState();
}

class _DetailRecordScreenState extends State<DetailRecordScreen> {
  static const String _emotionApiBaseUrl =
      'https://ongi-1049536928483.asia-northeast3.run.app';
  late Future<List<Emotion>> _emotionsFuture;
  final Set<String> _selectedEmotionCodes = {}; // description 대신 code를 저장
  final TextEditingController _commentController = TextEditingController();

  String _formatKoreanDate(DateTime date) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
  }

  @override
  void initState() {
    super.initState();
    _emotionsFuture = fetchEmotions();
  }

  Future<List<Emotion>> fetchEmotions() async {
    final service = MaumlogService(baseUrl: _emotionApiBaseUrl);
    return await service.fetchEmotions();
  }



  Future<void> _showPhotoUpdatePopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return const PhotoUpdatePopup();
      },
    );
  }

  Future<void> _showPhotoRemindPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return const PhotoRemindPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date ?? DateTime.now();
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // 뒤로가기
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: SvgPicture.asset('assets/images/back_icon_black.svg'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 날짜 오버레이
                Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ongiOrange,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    _formatKoreanDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                // 사진 카드 + 위치 오버레이
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1 / 1.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.file(
                                File(widget.backImagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (widget.frontImagePath != null)
                              Positioned(
                                top: 15,
                                left: 15,
                                width: 120,
                                height: 144,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.ongiOrange,
                                      width: 2.5,
                                    ),
                                    borderRadius: BorderRadius.circular(22.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22.5),
                                    child: Image.file(
                                      File(widget.frontImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            // 위치 오버레이
                            if (widget.address != null)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.place,
                                          color: AppColors.ongiOrange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.address!,
                                          style: const TextStyle(
                                            color: AppColors.ongiOrange,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Pretendard',
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
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // 감정 태그
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 감정은?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Emotion>>(
                        future: _emotionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.ongiOrange,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              '감정 불러오기 실패: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          final emotions = snapshot.data ?? [];
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: emotions.map((e) {
                              final selected = _selectedEmotionCodes.contains(
                                e.code,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _selectedEmotionCodes.remove(e.code);
                                    } else {
                                      _selectedEmotionCodes.add(e.code);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.ongiOrange
                                        : AppColors.ongiGrey,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    e.description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 코멘트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: PrefsManager.getUserInfo(),
                        builder: (context, snapshot) {
                          final userInfo = snapshot.data ?? {};
                          final profileImageId = userInfo['profileImageId'] ?? 0;
                          final profileImagePath = PrefsManager.getProfileImagePath(profileImageId);

                          return CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(profileImagePath),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextField(
                            controller: _commentController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 기록하기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ongiOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      onPressed: () async {
                        try {
                          // 업로드 전에 가족들의 기록 상태를 먼저 확인
                          final today = widget.date ?? DateTime.now();
                          final todayStr =
                              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

                          final userInfo = await PrefsManager.getUserInfo();
                          final currentUserName = userInfo['name'] ?? '';

                          final maumLogResponse = await MaumLogService.getMaumLog(todayStr);
                          final familyPhotos = maumLogResponse.maumLogDtos
                              .where((log) => log.uploader != currentUserName)
                              .toList();
                          final hasFamilyPhotos = familyPhotos.isNotEmpty;

                          final selectedEmotionCodes = _selectedEmotionCodes
                              .toList();
                          final comment = _commentController.text.trim();
                          final accessToken =
                          await PrefsManager.getAccessToken();

                          if (accessToken == null) {
                            throw Exception('로그인이 필요합니다. 다시 로그인해주세요.');
                          }

                          print('🔐저장된 토큰: $accessToken');

                          // 사용자 UUID 가져오기
                          final userUuid = await PrefsManager.getUuid();
                          if (userUuid == null) {
                            throw Exception('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
                          }

                          final service = MaumlogService(
                            baseUrl: _emotionApiBaseUrl,
                          );

                          final presignedData = await service.getPresignedUrls(
                            accessToken: accessToken,
                          );

                          final frontFileName =
                          presignedData['frontFileName'] as String;
                          final frontPresignedUrl =
                          presignedData['frontPresignedUrl'] as String;
                          final backFileName =
                          presignedData['backFileName'] as String;
                          final backPresignedUrl =
                          presignedData['backPresignedUrl'] as String;

                          await service.uploadFileToS3(
                            presignedUrl: backPresignedUrl,
                            file: File(widget.backImagePath),
                            uploaderUuid: userUuid,
                          );

                          final actualFrontFileName =
                          widget.frontImagePath != null
                              ? frontFileName
                              : backFileName;
                          if (widget.frontImagePath != null) {
                            await service.uploadFileToS3(
                              presignedUrl: frontPresignedUrl,
                              file: File(widget.frontImagePath!),
                              uploaderUuid: userUuid,
                            );
                          }

                          await service.uploadMaumLog(
                            frontFileName: actualFrontFileName,
                            backFileName: backFileName,
                            location: widget.address,
                            comment: comment.isNotEmpty ? comment : null,
                            emotions: selectedEmotionCodes,
                            accessToken: accessToken,
                          );

                          if (!mounted) return;

                          // 업로드 완료 후 업로드 전에 확인한 가족 상태에 따라 팝업 표시
                          if (hasFamilyPhotos) {
                            await _showPhotoUpdatePopup();
                          } else {
                            await _showPhotoRemindPopup();
                          }

                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '업로드 실패, $e',
                                style: const TextStyle(
                                  color: AppColors.ongiOrange,
                                ),
                              ),
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        '기록하기',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}