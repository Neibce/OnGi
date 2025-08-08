class Emotion {
  final String code;
  final String description;

  const Emotion({required this.code, required this.description});

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      code: json['code'],
      description: json['description'],
    );
  }
  
  // Emotion 목록
  static const List<Emotion> all = [
    Emotion(code: "JOYFUL", description: "즐거움"),
    Emotion(code: "EXCITED", description: "설렘"),
    Emotion(code: "RELIEVED", description: "마음이 놓임"),
    Emotion(code: "SMIRK", description: "뿌듯함"),
    Emotion(code: "SADNESS", description: "서글픔"),
    Emotion(code: "STIFLED", description: "답답함"),
    Emotion(code: "WARMHEARTED", description: "마음이 따뜻"),
    Emotion(code: "EMPTY", description: "허전함"),
    Emotion(code: "REFRESHING", description: "시원섭섭함"),
    Emotion(code: "THRILL", description: "들뜸"),
    Emotion(code: "ANNOYED", description: "짜증남"),
    Emotion(code: "SORROWFUL", description: "서운함"),
    Emotion(code: "WORRIED", description: "걱정스러움"),
    Emotion(code: "MISSING", description: "그리움"),
    Emotion(code: "DEPRESSED", description: "울적함"),
    Emotion(code: "RELAXED", description: "여유로움"),
    Emotion(code: "CONFUSED", description: "마음이 복잡함"),
    Emotion(code: "CHEERFUL", description: "기운이 남"),
    Emotion(code: "COZY", description: "포근함"),
  ];

  // description → code 변환
  static String descriptionToCode(String description) {
    final found = all.firstWhere(
      (e) => e.description == description,
      orElse: () => Emotion(code: description.toUpperCase(), description: description),
    );
    return found.code;
  }

  // code → description 변환
  static String codeToDescription(String code) {
    final found = all.firstWhere(
      (e) => e.code == code,
      orElse: () => Emotion(code: code, description: code),
    );
    return found.description;
  }
}

class MaumLogRecord {
  final int id;
  final String fileName;
  final String fileExtension;
  final String? location;
  final String? comment;
  final List<String> emotions; // Emotion code 리스트

  MaumLogRecord({
    required this.id,
    required this.fileName,
    required this.fileExtension,
    this.location,
    this.comment,
    required this.emotions,
  });

  factory MaumLogRecord.fromJson(Map<String, dynamic> json) {
    return MaumLogRecord(
      id: json['id'],
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      location: json['location'],
      comment: json['comment'],
      emotions: List<String>.from(json['emotions'] ?? []),
    );
  }
}