import 'package:flutter/material.dart';
import 'package:ongi/screens/health_log_screen.dart';
import 'package:ongi/screens/home_screen.dart';

class ParentInitScreen extends StatelessWidget {
  const ParentInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 40, top: 130),
            child: Text(
              '안녕하세요\n온기\n입니다',
              style: TextStyle(
                fontSize: 43,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          Center(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HealthLogScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 200),
                      padding: const EdgeInsets.all(24),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white30,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('건강\n기록', textAlign: TextAlign.left),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 200),
                      padding: const EdgeInsets.all(24),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white30,
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('홈', textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
