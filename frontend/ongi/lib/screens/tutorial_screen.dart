import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ongi/core/app_email_background.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.imageAssets});

  final List<String> imageAssets;

  // 앱 내부에서만 쓰는 고정 키 (버전 바꾸고 싶으면 문자열만 변경)
  static const String _TutorialFlagKey = 'v1';

  static Future<bool> showIfNeeded(
    BuildContext context, {
    required List<String> imageAssets,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_TutorialFlagKey) ?? false;
    if (seen) return false;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TutorialScreen(imageAssets: imageAssets),
        fullscreenDialog: true,
      ),
    );
    return true;
  }

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  PageController? _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 이미지 미리 로드(깜빡임 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final path in widget.imageAssets) {
        await precacheImage(AssetImage(path), context);
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _pageController = null;
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TutorialScreen._TutorialFlagKey, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == widget.imageAssets.length - 1;

    return Scaffold(
      // backgroundColor: AppColors.ongiOrange,
      backgroundColor: Colors.transparent,
      body: AppEmailBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: _finish,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLast ? null : Icons.skip_next_rounded,
                          color: AppColors.pillsItemBackground,
                          size: 38,
                        ),
                        if (!isLast) ...[
                          Text(
                            '건너뛰기',
                            style: TextStyle(
                              color: AppColors.pillsItemBackground,
                              fontSize: 11,
                              height: 0.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: _pageController != null
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageAssets.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (_, i) {
                          return Center(
                            child: InteractiveViewer(
                              child: Image.asset(
                                widget.imageAssets[i],
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageAssets.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(double.infinity, 35),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      if (isLast) {
                        await _finish();
                      } else {
                        final controller = _pageController;
                        if (controller != null && controller.hasClients) {
                          await controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                    },
                    child: Text(
                      isLast ? '시작하기' : '다음',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ongiOrange,
                      ),
                    ),
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
