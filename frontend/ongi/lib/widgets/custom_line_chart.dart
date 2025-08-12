import 'package:flutter/material.dart';
import 'package:ongi/widgets/custom_line_chart_painter.dart';

class CustomLineChart extends StatelessWidget {
  final double current;
  final double max;

  const CustomLineChart({super.key, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final size = Size(MediaQuery.of(context).size.width * 0.95, 16);
    return CustomPaint(
        painter: CustomLineChartPainter(current: current, max: max),
        size: size,
      );
  }
}
