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
}

class MaumLogRecord {
  final int id;
  final String fileName;
  final String fileExtension;
  final String? location;
  final String? comment;
  final List<String> emotions; // Emotion 리스트

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