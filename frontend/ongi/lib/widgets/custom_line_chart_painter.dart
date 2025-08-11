// custom_line_chart_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLineChartPainter extends CustomPainter {
  final double current;
  final double max;

  CustomLineChartPainter({required this.current, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    // --- sizes & colors ---
    final barRadius = Radius.circular(size.height / 2);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      barRadius,
    );

    // 바 안쪽 여백(진행바가 모서리에 붙지 않게)
    final inset = size.height * 0.25;
    final innerLeft = inset;
    final innerRight = size.width - inset;
    final innerTop = inset;
    final innerBottom = size.height - inset;

    final ratio = max <= 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
    final progressRight = innerLeft + (innerRight - innerLeft) * ratio;

    // --- background with soft shadow/gradient ---

    // 라이트 그라데이션 배경
    final bgPaint = Paint()..color = Colors.white;

    canvas.drawRRect(bgRect, bgPaint);
    _drawInnerShadow(
      canvas,
      bgRect,
      color: Colors.black26,
      blur: 4,
      offset: const Offset(0, 3.5),
      spread: 20,
    );

    // --- progress (orange) ---
    if (progressRight > innerLeft) {
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(innerLeft, innerTop, progressRight, innerBottom),
        Radius.circular((innerBottom - innerTop) / 2),
      );
      final progressPaint = Paint()..color = const Color(0xFFFF7A00); // 오렌지
      canvas.drawRRect(progressRect, progressPaint);
    }

    // --- bubble above (pill + tail) ---
    // 라벨 텍스트
    final label = "${current.toStringAsFixed(1)}°C";
    final fontSize = math.max(11.0, size.height * 0.45); // 높이에 비례
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bubbleHPad = 10.0;
    final bubbleVPad = 2.5;
    final bubbleW = tp.width + bubbleHPad * 2;
    final bubbleH = tp.height + bubbleVPad * 2;
    final tailW = 13.0;
    final tailH = 5.0;
    final gap = 8.0; // 바와 말풍선 사이 간격

    // 진행 끝점 X (바 내부 기준)
    final tipX = progressRight;
    // 말풍선이 캔버스 밖으로 나가지 않도록 중앙 X를 클램프
    final bubbleCenterX = tipX.clamp(bubbleW / 2, size.width - bubbleW / 2);
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(bubbleCenterX, -gap - bubbleH / 2), // 바 위쪽에 위치
        width: bubbleW,
        height: bubbleH,
      ),
      const Radius.circular(999),
    );

    // 꼬리의 중앙 X: 말풍선 폭 안에서만 움직이게 클램프
    final tailCenterX = tipX.clamp(
      bubbleRect.left + tailW / 2 + 2,
      bubbleRect.right - tailW / 2 - 2,
    );

    final bubblePaint = Paint()..color = const Color(0xFFFF7A00);

    canvas.drawRRect(bubbleRect, bubblePaint);

    final tail = Path()
      ..moveTo(tailCenterX - tailW / 2, bubbleRect.outerRect.bottom - 5)
      ..lineTo(tailCenterX + tailW / 2, bubbleRect.outerRect.bottom - 5)
      ..lineTo(tipX, bubbleRect.outerRect.bottom + tailH)
      ..close();
    canvas.drawPath(tail, bubblePaint);

    // 텍스트(가운데 정렬)
    final textOffset = Offset(
      bubbleRect.outerRect.left + (bubbleW - tp.width) / 2,
      bubbleRect.outerRect.top + (bubbleH - tp.height) / 2,
    );
    tp.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomLineChartPainter old) {
    return current != old.current || max != old.max;
  }

  void _drawInnerShadow(
    Canvas canvas,
    RRect rrect, {
    Color color = const Color(0x33000000), // 그림자 색/강도
    double blur = 8, // 퍼짐 정도
    Offset offset = const Offset(0, 2), // 광원 방향(그림자 위치)
    double spread = 20, // 바깥 경계 얼마나 키워서 블러 줄지
  }) {
    // 안쪽만 보이게 클립
    canvas.save();
    canvas.clipRRect(rrect);

    final outer = rrect.inflate(spread); // 더 큰 RRect
    final path = Path()
      ..addRRect(outer)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd; // 바깥 - 안쪽 링

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // 살짝 이동시켜서 방향감
    canvas.drawPath(path.shift(offset), paint);

    canvas.restore();
  }
}
