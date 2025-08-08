import 'package:intl/intl.dart';

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
  final String userName;
  final String formattedChange;
  final String formattedDate;
  final double temperature;
  final DateTime dateTime;
  final double contributed;

  Contribution({
    required this.userName,
    required this.formattedChange,
    required this.formattedDate,
    required this.temperature,
    required this.dateTime,
    required this.contributed,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.parse(json['dateTime']);
    final contributed = (json['contributed'] ?? 0).toDouble();
    return Contribution(
      userName: json['userName'] ?? '',
      formattedChange: '+${contributed.toStringAsFixed(1)}°',
      formattedDate: '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
      temperature: (json['temperature'] ?? 0).toDouble(),
      contributed: contributed,
      dateTime: dateTime,
    );
  }
}
