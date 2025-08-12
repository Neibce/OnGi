import 'package:flutter/material.dart';

class DayCircles extends StatelessWidget {
  final List<Color> appColors;
  final EdgeInsets padding;

  const DayCircles({
    Key? key,
    required this.appColors,
    this.padding = EdgeInsets.zero,
  }) : assert(appColors.length == 4),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 19;
    double overlap = 9;

    return Padding(
      padding: padding,
      child: SizedBox(
        width: size * 2 + overlap * 2,
        height: size * 2 + overlap * 2,
        child: Stack(
          children: [
            _buildCircle(appColors[3], size - overlap, size - overlap, size),
            _buildCircle(appColors[2], 0, size - overlap, size),
            _buildCircle(appColors[1], size - overlap, 0, size),
            _buildCircle(appColors[0], 0, 0, size),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
