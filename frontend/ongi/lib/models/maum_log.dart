class MaumLogResponse {
  final bool hasUploadedOwn;
  final List<MaumLogDto> maumLogDtos;

  MaumLogResponse({
    required this.hasUploadedOwn,
    required this.maumLogDtos,
  });

  factory MaumLogResponse.fromJson(Map<String, dynamic> json) {
    var list = json['maumLogDtos'] as List<dynamic>? ?? [];
    return MaumLogResponse(
      hasUploadedOwn: json['hasUploadedOwn'] ?? false,
      maumLogDtos: list.map((e) => MaumLogDto.fromJson(e)).toList(),
    );
  }
}

class MaumLogDto {
  final String frontPresignedUrl;
  final String backPresignedUrl;
  final String comment;
  final String location;
  final List<String> emotions;
  final String uploader;

  MaumLogDto({
    required this.frontPresignedUrl,
    required this.backPresignedUrl,
    required this.comment,
    required this.location,
    required this.emotions,
    required this.uploader,
  });

  factory MaumLogDto.fromJson(Map<String, dynamic> json) {
    var emotionsList = json['emotions'] as List<dynamic>? ?? [];
    return MaumLogDto(
      frontPresignedUrl: json['frontPresignedUrl'] ?? '',
      backPresignedUrl: json['backPresignedUrl'] ?? '',
      comment: json['comment'] ?? '',
      location: json['location'] ?? '',
      emotions: emotionsList.map((e) => e.toString()).toList(),
      uploader: json['uploader'] ?? '',
    );
  }

  // Helper method to get formatted emotions for display
  List<String> get formattedEmotions {
    return emotions.map((emotion) {
      switch (emotion) {
        case 'JOYFUL':
          return '즐거움';
        case 'EXCITED':
          return '설렘';
        case 'RELIEVED':
          return '마음이 놓임';
        case 'SMIRK':
          return '뿌듯함';
        case 'SADNESS':
          return '서글픔';
        case 'STIFLED':
          return '답답함';
        case 'WARMHEARTED':
          return '마음이 따뜻';
        case 'EMPTY':
          return '허전함';
        case 'REFRESHING':
          return '시원섭섭함';
        case 'THRILL':
          return '들뜸';
        case 'ANNOYED':
          return '짜증남';
        case 'SORROWFUL':
          return '서운함';
        case 'WORRIED':
          return '걱정스러움';
        case 'MISSING':
          return '그리움';
        case 'DEPRESSED':
          return '울적함';
        case 'RELAXED':
          return '여유로움';
        case 'CONFUSED':
          return '마음이 복잡함';
        case 'CHEERFUL':
          return '기운이 남';
        case 'COZY':
          return '포근함';
        default:
          return emotion;
      }
    }).toList();
  }
}
