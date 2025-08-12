import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/maumlog_service.dart';
import 'package:ongi/services/maum_log_service.dart';
import 'package:ongi/models/maumlog.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:ongi/screens/photo/photo_remind_popup.dart';
import 'package:ongi/screens/photo/photo_update_popup.dart';

class DetailRecordScreen extends StatefulWidget {
  final String backImagePath;
  final String? frontImagePath;
  final String? address;
  final DateTime? date;
  const DetailRecordScreen({super.key, required this.backImagePath, this.frontImagePath, this.address, this.date});

  @override
  State<DetailRecordScreen> createState() => _DetailRecordScreenState();
}

class _DetailRecordScreenState extends State<DetailRecordScreen> {
  static const String _emotionApiBaseUrl = 'https://ongi-1049536928483.asia-northeast3.run.app';
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

  Future<void> _checkFamilyPhotoStatusAndShowPopup() async {
    try {
      // 오늘 날짜 형식으로
      final today = widget.date ?? DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // 현재 사용자 정보 가져오기
      final userInfo = await PrefsManager.getUserInfo();
      final currentUserName = userInfo['name'] ?? '';
      
      // 가족들의 마음 기록 상태 확인
      final maumLogResponse = await MaumLogService.getMaumLog(todayStr);
      
      if (!mounted) return;
      
      // 현재 사용자 제외한 다른 가족이 사진을 업로드했는지 확인
      final familyPhotos = maumLogResponse.maumLogDtos.where(
        (log) => log.uploader != currentUserName
      ).toList();
      
      final hasFamilyPhotos = familyPhotos.isNotEmpty;
      
      if (hasFamilyPhotos) {
        // 가족들이 사진을 올렸으면 photo_update_popup 보여주기
        await _showPhotoUpdatePopup();
      } else {
        // 가족들이 사진을 올리지 않았으면 photo_remind_popup 보여주기
        await _showPhotoRemindPopup();
      }
      
      // 팝업이 닫힌 후 화면 종료
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('가족 사진 상태 확인 중 오류: $e');
      // 오류 발생 시 기본 완료 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 저장되었습니다!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showPhotoUpdatePopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PhotoUpdatePopup();
      },
    );
  }

  Future<void> _showPhotoRemindPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
                // 상단 아이콘들
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.black54),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.black54),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 날짜 오버레이
                Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                                        Icon(Icons.place, color: AppColors.ongiOrange, size: 18),
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
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('감정 불러오기 실패: ${snapshot.error}', style: TextStyle(color: Colors.red));
                          }
                          final emotions = snapshot.data ?? [];
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: emotions.map((e) {
                              final selected = _selectedEmotionCodes.contains(e.code);
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.ongiOrange : AppColors.ongiGrey,
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
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/images/users/elderly_woman.png'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ongiOrange,
                        foregroundColor: Colors.white,
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
                          final selectedEmotionCodes = _selectedEmotionCodes.toList();
                          final comment = _commentController.text.trim();
                          final accessToken = await PrefsManager.getAccessToken();
                          
                          if (accessToken == null) {
                            throw Exception('로그인이 필요합니다. 다시 로그인해주세요.');
                          }
                          
                          print('🔐저장된 토큰: $accessToken');
                          
                          // 사용자 UUID 가져오기
                          final userUuid = await PrefsManager.getUuid();
                          if (userUuid == null) {
                            throw Exception('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
                          }
                          
                          final service = MaumlogService(baseUrl: _emotionApiBaseUrl);
                          
                          final presignedData = await service.getPresignedUrls(
                            accessToken: accessToken,
                          );
                          
                          final frontFileName = presignedData['frontFileName'] as String;
                          final frontPresignedUrl = presignedData['frontPresignedUrl'] as String;
                          final backFileName = presignedData['backFileName'] as String;
                          final backPresignedUrl = presignedData['backPresignedUrl'] as String;
                          
                          await service.uploadFileToS3(
                            presignedUrl: backPresignedUrl,
                            file: File(widget.backImagePath),
                            uploaderUuid: userUuid,
                          );
                          
                          final actualFrontFileName = widget.frontImagePath != null ? frontFileName : backFileName;
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
                          
                          // 기록 저장 후 가족들의 사진 업로드 상태 확인
                          await _checkFamilyPhotoStatusAndShowPopup();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('업로드 실패: $e')),
                          );
                        }
                      },
                      child: const Text('기록하기'),
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
