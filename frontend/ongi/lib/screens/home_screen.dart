import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background logo (top right)
          Positioned(
            top: -140,
            right: -200,
            child: Opacity(
              opacity: 0.30,
              child: Image.asset(
                'assets/images/logo.png',
                width: 480,
                height: 480,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 60,
                      color: AppColors.ongiOrange,
                    ),
                    children: const [
                      TextSpan(
                        text: '우리 가족의 ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '온기는',
                        style: TextStyle(fontWeight: FontWeight.w700), // 굵게!
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular temperature graph
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CustomPaint(painter: _TempArcPainter()),
                            ),
                            const Positioned(
                              left: 36,
                              top: 70,
                              child: Text(
                                '36.5',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36,
                                  color: AppColors.ongiOrange,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 120,
                              top: 90,
                              child: Text(
                                '℃',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: AppColors.ongiOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right side buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CircleButton(
                            icon: Icons.sync,
                            color: AppColors.ongiOrange,
                            iconColor: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          _CircleButton(
                            icon: Icons.location_on,
                            color: Colors.white,
                            iconColor: AppColors.ongiOrange,
                            border: true,
                          ),
                          const SizedBox(height: 16),
                          _CircleButton(
                            icon: Icons.directions_run,
                            color: Colors.white,
                            iconColor: AppColors.ongiOrange,
                            border: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TempArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ongiOrange
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Draw arc (about 270 degrees)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.14 * 0.7,
      3.14 * 1.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final bool border;
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    this.border = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border
            ? Border.all(color: AppColors.ongiOrange, width: 2)
            : null,
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}
