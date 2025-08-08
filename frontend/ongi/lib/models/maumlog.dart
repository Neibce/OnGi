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