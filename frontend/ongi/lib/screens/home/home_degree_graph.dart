import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/screens/home/home_ourfamily_text_withoutUser.dart';

final List<String> dates = ['6/11', '6/12', '6/13', '6/14', '6/15'];
final List<double> temps = [36.2, 35.8, 37.2, 38.0, 38.6];
final List<FlSpot> spots = List.generate(
  temps.length,
  (i) => FlSpot(i.toDouble(), temps[i]),
);

class HomeDegreeGraph extends StatefulWidget {
  final VoidCallback? onBack;
  const HomeDegreeGraph({super.key, this.onBack});

  @override
  State<HomeDegreeGraph> createState() => _HomeDegreeGraph();
}

class _HomeDegreeGraph extends State<HomeDegreeGraph> {
  bool showHistory = false;

  final List<Map<String, String>> history = [
    {"name": "양금명님", "change": "+0.3°C", "date": "25.06.15 22:07"},
    {"name": "양은명님", "change": "+0.1°C", "date": "25.06.14 20:55"},
    {"name": "양관식님", "change": "+0.2°C", "date": "25.06.14 17:14"},
    {"name": "양관식님", "change": "+0.2°C", "date": "25.06.13 17:14"},
    {"name": "양관식님", "change": "+0.2°C", "date": "25.06.13 17:14"},
    {"name": "양관식님", "change": "+0.1°C", "date": "25.06.13 17:14"},
    {"name": "오애순님", "change": "+0.2°C", "date": "25.06.13 15:09"},
    {"name": "오애순님", "change": "+0.2°C", "date": "25.06.13 15:08"},
    {"name": "오애순님", "change": "+0.2°C", "date": "25.06.13 15:08"},
    {"name": "오애순님", "change": "+0.1°C", "date": "25.06.13 15:07"},
    {"name": "양금명님", "change": "+0.1°C", "date": "25.06.13 12:28"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ongiLigntgrey,
      body: AppLightBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기
              GestureDetector(
                onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 32,
                    top: MediaQuery.of(context).size.height * 0.08,
                  ),
                  child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
                ),
              ),
              // 타이틀
              const HomeOngiTextWithoutUser(),
              // 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: showHistory
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
    if (history.isNotEmpty) {
      latestName = history[0]['name'] ?? '';
      latestChange = history[0]['change'] ?? '';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 270,
          child: LineChart(
            LineChartData(
              minY: 35.2,
              maxY: 40.5,
              minX: 0,
              maxX: (dates.length - 1).toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    getTitlesWidget: (value, meta) {
                      if (value == 35.2 || value == 40.5) return const SizedBox.shrink();
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
                      if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
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
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: Colors.orange,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
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
              ? '최근 $latestName 님이 $latestChange 상승 시켰어요!'
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
            itemCount: history.length,
            itemBuilder: (context, idx) {
              final item = history[idx];
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
                      if (idx != history.length - 1)
                        Container(
                          width: 2,
                          height: 24,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${item['name']}이 ${item['change']} 상승 시켰어요!",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                  Text(
                    item['date'] ?? '',
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
