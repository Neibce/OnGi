import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class CustomChartPainter extends CustomPainter {
  final List<double> percentages;

  CustomChartPainter({required this.percentages});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius * 0.65;

    final int segmentCount = percentages.length;
    final double totalAngle = 2 * pi;
    final double gapAngle = 0.185;
    final double totalGaps = gapAngle * segmentCount;

    final double totalPercentage = percentages.reduce((a, b) => a + b);
    final List<double> normalizedPercentages = percentages
        .map((p) => p / totalPercentage)
        .toList();

    final List<double> segmentAngles = normalizedPercentages
        .map((p) => p * (totalAngle - totalGaps))
        .toList();

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFFFD6C01), Color(0xFFBFECFF)],
      stops: [0.1, 0.9],
    );

    final shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: outerRadius),
    );
    final double outerCornerRadius = 10.0;
    final double innerCornerRadius = outerCornerRadius * 0.65;

    Paint shadowPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = outerRadius - innerRadius + 35
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

    Paint whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = outerRadius - innerRadius + 35
      ..style = PaintingStyle.stroke;

    Offset shadowOffset = Offset(center.dx, center.dy + 2);
    canvas.drawArc(
      Rect.fromCircle(
        center: shadowOffset,
        radius: (outerRadius + innerRadius) / 2,
      ),
      0,
      2 * pi,
      false,
      shadowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
      0,
      2 * pi,
      false,
      whitePaint,
    );

    double currentAngle = -pi / 2 + gapAngle / 2;

    for (int i = 0; i < segmentCount; i++) {
      final double startAngle = currentAngle;
      final double endAngle = startAngle + segmentAngles[i];
      currentAngle = endAngle + gapAngle;

      Path path = Path();

      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        segmentAngles[i],
        false,
      );

      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        endAngle,
        -segmentAngles[i],
        false,
      );

      final Offset startInner = Offset(
        center.dx + innerRadius * cos(startAngle),
        center.dy + innerRadius * sin(startAngle),
      );
      final Offset startOuter = Offset(
        center.dx + outerRadius * cos(startAngle),
        center.dy + outerRadius * sin(startAngle),
      );

      final Offset endInner = Offset(
        center.dx + innerRadius * cos(endAngle),
        center.dy + innerRadius * sin(endAngle),
      );
      final Offset endOuter = Offset(
        center.dx + outerRadius * cos(endAngle),
        center.dy + outerRadius * sin(endAngle),
      );

      path.moveTo(endOuter.dx, endOuter.dy);
      path.addOval(
        Rect.fromCircle(
          center: getPointAtDistance(endOuter, endInner, outerCornerRadius),
          radius: outerCornerRadius,
        ),
      );
      path.addOval(
        Rect.fromCircle(
          center: getPointAtDistance(endInner, endOuter, innerCornerRadius),
          radius: innerCornerRadius,
        ),
      );

      path.addOval(
        Rect.fromCircle(
          center: getPointAtDistance(startOuter, startInner, outerCornerRadius),
          radius: outerCornerRadius,
        ),
      );
      path.addOval(
        Rect.fromCircle(
          center: getPointAtDistance(startInner, startOuter, innerCornerRadius),
          radius: innerCornerRadius,
        ),
      );

      Offset ovalEndOuter = moveAlongCircle(
        center: center,
        radius: outerRadius - outerCornerRadius,
        startAngle: endAngle,
        distance: outerCornerRadius,
      );
      Offset ovalEndInner = moveAlongCircle(
        center: center,
        radius: innerRadius + innerCornerRadius,
        startAngle: endAngle,
        distance: innerCornerRadius,
      );

      Offset ovalStartOuter = moveAlongCircle(
        center: center,
        radius: outerRadius - outerCornerRadius,
        startAngle: startAngle,
        distance: 0,
      );
      Offset ovalStartInner = moveAlongCircle(
        center: center,
        radius: innerRadius + innerCornerRadius,
        startAngle: startAngle,
        distance: 0,
      );

      path.addPath(
        buildSkewedRect(
          ovalEndOuter,
          ovalEndInner,
          outerCornerRadius,
          innerCornerRadius,
        ),
        Offset.zero,
      );

      path.addPath(
        buildSkewedRect(
          ovalStartOuter,
          ovalStartInner,
          outerCornerRadius,
          innerCornerRadius,
        ),
        Offset.zero,
      );
      path.close();

      final Paint segmentPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, segmentPaint);
    }
  }

  Offset getPointAtDistance(Offset p1, Offset p2, double distance) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);

    if (len == 0) return p1; // 두 점이 같을 경우

    final ratio = distance / len;
    return Offset(p1.dx + dx * ratio, p1.dy + dy * ratio);
  }

  Path buildSkewedRect(
    Offset topLeft,
    Offset bottomLeft,
    double outerWidth,
    double innerWidth,
  ) {
    final dx = bottomLeft.dx - topLeft.dx;
    final dy = bottomLeft.dy - topLeft.dy;
    final length = sqrt(dx * dx + dy * dy);

    final nx = -dy / length;
    final ny = dx / length;

    final topRight = Offset(
      topLeft.dx + nx * outerWidth,
      topLeft.dy + ny * outerWidth,
    );
    final bottomRight = Offset(
      bottomLeft.dx + nx * innerWidth,
      bottomLeft.dy + ny * innerWidth,
    );

    final path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    return path;
  }

  Offset moveAlongCircle({
    required Offset center,
    required double radius,
    required double startAngle,
    required double distance,
  }) {
    if (radius == 0) return center;

    final double deltaAngle = distance / radius;
    final double newAngle = startAngle + deltaAngle;

    return Offset(
      center.dx + radius * cos(newAngle),
      center.dy + radius * sin(newAngle),
    );
  }

  @override
  bool shouldRepaint(covariant CustomChartPainter oldDelegate) {
    return !listEquals(percentages, oldDelegate.percentages);
  }
}
