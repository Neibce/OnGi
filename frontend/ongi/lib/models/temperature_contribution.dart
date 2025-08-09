class FamilyTemperatureContributionResponse {
  final List<Contribution> contributions;

  FamilyTemperatureContributionResponse({required this.contributions});

  factory FamilyTemperatureContributionResponse.fromJson(Map<String, dynamic> json) {
    var list = json['contributions'] as List<dynamic>? ?? [];
    return FamilyTemperatureContributionResponse(
      contributions: list.map((e) => Contribution.fromJson(e)).toList(),
    );
  }
}

class Contribution {
  final DateTime dateTime;
  final String userName;
  final String reason;
  final double contributed;

  Contribution({
    required this.dateTime,
    required this.userName,
    required this.reason,
    required this.contributed,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      dateTime: DateTime.parse(json['dateTime']),
      userName: json['userName'] ?? '',
      reason: json['reason'] ?? '',
      contributed: (json['contributed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get formattedDate => '${dateTime.year % 100}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  String get formattedChange => (contributed > 0 ? '+' : '') + contributed.toStringAsFixed(1) + '°C';
}