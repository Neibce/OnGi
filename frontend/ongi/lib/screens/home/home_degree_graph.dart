import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/core/app_light_background.dart';
import 'package:ongi/screens/home/home_ourfamily_text_withoutUser.dart';
import 'package:flutter_charts/flutter_charts.dart';

final List<String> dates = ['6/11', '6/12', '6/13', '6/14', '6/15'];
final List<double> temps = [36.2, 35.8, 37.2, 38.0, 38.6];

class HomeDegreeGraph extends StatefulWidget{
  final VoidCallback? onBack;
  const HomeDegreeGraph({super.key, this.onBack});

  @override
  State<HomeDegreeGraph> createState() => _HomeDegreeGraph();
}

class _HomeDegreeGraph extends State<HomeDegreeGraph> {
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
              // 그래프 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: FamilyTempGraphPainter(dates, temps),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '최근 양금명 님이 +0.3°C 상승 시켰어요!',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//
// class LineChart extends StatelessWidget {
//   const LineChart({
//     super.key,
//     required this.dataList,
//     required this.markerColor,
//     required this.baseValue,
//   });
//
//   final List<LineChartData> dataList;
//   final Color markerColor;
//   final double baseValue;
//
//   @override
//   Widget chartToRun() {
//     LabelLayoutStrategy? xContainerLabelLayoutStrategy;
//     ChartData chartData;
//     ChartOptions chartOptions = const ChartOptions();
//     // Example shows a demo-type data generated randomly in a range.
//     chartData = RandomChartData.generated(chartOptions: chartOptions);
//     var lineChartContainer = LineChartTopContainer(
//       chartData: chartData,
//       xContainerLabelLayoutStrategy: xContainerLabelLayoutStrategy,
//     );
//
//     var lineChart = LineChart(
//       painter: LineChartPainter(
//         lineChartContainer: lineChartContainer,
//       ),
//     );
//     return lineChart;
//   }
// }
//
// // 차트 데이터 클래스
// class LineChartData {
//   final String name;
//   final double value;
//
//   LineChartData(this.name, this.value);
// }

// 간단한 CustomPainter 예시 (실제 앱에서는 fl_chart 등 패키지 사용 추천)
class FamilyTempGraphPainter extends CustomPainter {
  final List<String> dates;
  final List<double> temps;
  FamilyTempGraphPainter(this.dates, this.temps);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // 축 그리기
    final double minY = 35.5, maxY = 40.0;
    final double leftMargin = 32, bottomMargin = 32, topMargin = 16;
    final double chartWidth = size.width - leftMargin;
    final double chartHeight = size.height - bottomMargin - topMargin;

    // y축 라벨 및 선
    for (int i = 0; i <= 5; i++) {
      double y = topMargin + chartHeight * i / 5;
      double value = maxY - (maxY - minY) * i / 5;
      final textSpan = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 8));
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        Paint()..color = Colors.grey[300]!,
      );
    }

    // x축 라벨
    for (int i = 0; i < dates.length; i++) {
      double x = leftMargin + chartWidth * i / (dates.length - 1);
      final textSpan = TextSpan(
        text: dates[i],
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomMargin + 8));
    }

    // 그래프 선 및 점
    Path path = Path();
    for (int i = 0; i < temps.length; i++) {
      double x = leftMargin + chartWidth * i / (temps.length - 1);
      double y = topMargin + chartHeight * (maxY - temps[i]) / (maxY - minY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, paintDot);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}