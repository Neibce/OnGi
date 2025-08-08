import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/maumlog_service.dart';
import 'package:ongi/models/maumlog.dart';

class DetailRecordScreen extends StatefulWidget {
  final String imagePath;
  final String? address;
  final DateTime? date;
  const DetailRecordScreen({super.key, required this.imagePath, this.address, this.date});

  @override
  State<DetailRecordScreen> createState() => _DetailRecordScreenState();
}

class _DetailRecordScreenState extends State<DetailRecordScreen> {
  static const String _emotionApiBaseUrl = 'http://10.0.2.2:8080';
  late Future<List<Emotion>> _emotionsFuture;
  final Set<String> _selectedEmotions = {};
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
    final service = EmotionService(baseUrl: _emotionApiBaseUrl);
    return await service.fetchEmotions();
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
                            // ⬇️ 배경 이미지
                            Positioned.fill(
                              child: Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // ⬇️ 위치 오버레이
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
                              final selected = _selectedEmotions.contains(e.description);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _selectedEmotions.remove(e.description);
                                    } else {
                                      _selectedEmotions.add(e.description);
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
                // 코멘트 입력란
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
                          final file = File(widget.imagePath);
                          final fileName = file.uri.pathSegments.last;
                          final fileExtension = fileName.split('.').last;
                          final selectedEmotionCodes = _selectedEmotions.map((desc) => Emotion.descriptionToCode(desc)).toList();
                          final service = EmotionService(baseUrl: _emotionApiBaseUrl);
                          await service.uploadMaumLog(
                            fileName: fileName,
                            fileExtension: fileExtension,
                            location: widget.address,
                            comment: _commentController.text,
                            emotions: selectedEmotionCodes,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('기록이 저장되었습니다!')),
                          );
                          Navigator.of(context).pop();
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
