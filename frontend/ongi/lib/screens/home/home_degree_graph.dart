import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/screens/home/home_ourfamily_text_withoutUser.dart';
import 'package:ongi/services/temperature_service.dart';
import 'package:ongi/models/temperature_contribution.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeDegreeGraph extends StatefulWidget {
  final VoidCallback? onBack;
  const HomeDegreeGraph({super.key, this.onBack});

  @override
  State<HomeDegreeGraph> createState() => _HomeDegreeGraph();
}

class _HomeDegreeGraph extends State<HomeDegreeGraph> {
  bool showHistory = false;
  bool isLoading = true;
  String? errorMsg;
  List<Contribution> contributions = [];

  Future<void> ensureFamilyCode() async {
    final userInfo = await PrefsManager.getUserInfo();
    if (userInfo['familycode'] == null || userInfo['familycode']!.isEmpty) {
      final token = await PrefsManager.getAccessToken();
      if (token == null) return;
      final url = Uri.parse('https://ongi-1049536928483.asia-northeast3.run.app/family');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await PrefsManager.saveFamilyCodeAndName(data['code'] ?? '', data['name'] ?? '');
      }
    }
  }

  // 5일간 온도 총합 데이터
  List<Map<String, dynamic>> dailyTemperatures = [];

  List<FlSpot> get spots {
    return List.generate(
      dailyTemperatures.length,
          (i) => FlSpot(i.toDouble(), dailyTemperatures[i]['totalTemperature'] ?? 36.5),
    );
  }

  // 날짜 포맷
  List<String> get dates {
    return dailyTemperatures.map((e) {
      final date = DateTime.parse(e['date']);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }).toList();
  }

  double get yCenter {
    if (dailyTemperatures.isEmpty) return 36.5;
    final temps = dailyTemperatures.map((e) => (e['totalTemperature'] ?? 36.5) as double).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    return (minTemp + maxTemp) / 2;
  }

  double get minY {
    if (dailyTemperatures.isEmpty) return 36.5;
    final temps = dailyTemperatures.map((e) => (e['totalTemperature'] ?? 36.5) as double).toList();
    return temps.reduce((a, b) => a < b ? a : b);
  }

  double get maxY {
    if (dailyTemperatures.isEmpty) return 36.5;
    final temps = dailyTemperatures.map((e) => (e['totalTemperature'] ?? 36.5) as double).toList();
    return temps.reduce((a, b) => a > b ? a : b);
  }

  double get horizontalInterval {
    if ((maxY - minY) == 0) return 0.1;
    return (maxY - minY) / 9;
  }

  Future<void> fetchAllTemperatureData() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final userInfo = await PrefsManager.getUserInfo();
      final familyCode = userInfo['familycode'];
      final token = await PrefsManager.getAccessToken();
      if (familyCode == null) throw Exception('가족 코드가 없습니다.');
      final service = TemperatureService(baseUrl: 'https://ongi-1049536928483.asia-northeast3.run.app');
      final dailyResp = await service.fetchFamilyTemperatureDaily(familyCode, token: token);
      final contribResp = await service.fetchFamilyTemperatureContributions(familyCode, token: token);
      if (!mounted) return;
      setState(() {
        dailyTemperatures = dailyResp;
        contributions = contribResp.map((e) => Contribution.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ensureFamilyCode().then((_) => fetchAllTemperatureData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ongiLigntgrey,
      body: AppLightBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기!
              GestureDetector(
                onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    top: MediaQuery.of(context).size.height * 0.06,
                  ),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: SvgPicture.asset(
                      'assets/images/back_icon_black.svg',
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              // 타이틀
              const HomeOngiTextWithoutUser(),
              // 카드
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMsg != null
                      ? Center(child: Text(errorMsg!))
                      : showHistory
                      ? _buildHistoryList()
                      : _buildGraphCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphCard() {
    String latestName = '';
    String latestChange = '';
    bool isRise = true;
    if (contributions.isNotEmpty) {
      latestName = contributions[0].userName;
      latestChange = contributions[0].formattedChange;
      isRise = contributions[0].contributed >= 0;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 270,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: -0.5,
              maxX: (dates.length - 0.5),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: horizontalInterval,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey[300], strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: horizontalInterval,
                    getTitlesWidget: (value, meta) {
                      if (value < minY || value > maxY)
                        return const SizedBox.shrink();
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontFamily: 'Pretendard',
                        ),
                      );
                    },
                    reservedSize: 36,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      int idx = value.toInt();
                      if (idx < 0 || idx >= dates.length)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dates[idx],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      );
                    },
                    interval: 1,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: Colors.orange,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: Colors.orange,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          latestName.isNotEmpty && latestChange.isNotEmpty
              ? '최근 $latestName 님이 $latestChange ${isRise ? '상승' : '하강'} 시켰어요!'
              : '최근 온도 변화 데이터가 없습니다.',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontFamily: 'Pretendard',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          onPressed: () => setState(() => showHistory = true),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
          onPressed: () => setState(() => showHistory = false),
        ),
        SizedBox(
          height: 290,
          child: ListView.builder(
            itemCount: contributions.length,
            itemBuilder: (context, idx) {
              final item = contributions[idx];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽 선과 원
                  Column(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                          color: Colors.white,
                        ),
                      ),
                      if (idx != contributions.length - 1)
                        Container(width: 2, height: 24, color: Colors.orange),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${item.userName}이 ${item.formattedChange} 상승 시켰어요!",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                  Text(
                    item.formattedDate ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
