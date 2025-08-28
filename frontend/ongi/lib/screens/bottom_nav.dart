import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ongi/screens/add_record_screen.dart';
import 'package:ongi/screens/home/home_screen.dart';
import 'package:ongi/screens/health/health_home_screen.dart';
import 'package:ongi/screens/photo/photo_calendar_screen.dart';
import 'package:ongi/screens/mypage/mypage_screen.dart';
import 'package:ongi/core/app_colors.dart';
import 'package:ongi/services/maum_log_service.dart';
import 'package:ongi/services/health_record_status_service.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:intl/intl.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex;
  const BottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _currentIndex;
  bool _showTooltip = false;
  bool _isCheckingHealthRecord = false;
  bool _isParent = false;

  final List<Widget> _screens = [
    HomeScreen(key: homeScreenKey),
    HealthHomeScreen(key: healthHomeScreenKey),
    PhotoCalendarScreen(key: photoCalendarScreenKey),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _checkUserTypeAndHealthRecord();
    
    // 초기 화면이 홈이면 데이터 새로고침 (로그인 후 진입 시)
    if (_currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshHomeData();
      });
    }
    
    // 초기 화면이 건강기록이면 건강 데이터 새로고침 (parent_init_screen에서 건강기록 선택 시)
    if (_currentIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshHealthData();
      });
    }
  }

  Future<void> _checkUserTypeAndHealthRecord() async {
    if (_isCheckingHealthRecord) return;

    setState(() {
      _isCheckingHealthRecord = true;
    });

    try {
      final isParent = await PrefsManager.getIsParent();
      _isParent = isParent;

      if (_isParent) {
        final hasRecord =
            await HealthRecordStatusService.hasTodayHealthRecord();
        if (mounted) {
          setState(() {
            _showTooltip = !hasRecord;
            _isCheckingHealthRecord = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _showTooltip = false;
            _isCheckingHealthRecord = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showTooltip = false;
          _isCheckingHealthRecord = false;
        });
      }
    }
  }

  Future<void> _checkHealthRecordStatus() async {
    if (!_isParent) return;

    await _checkUserTypeAndHealthRecord();
  }

  Future<void> _refreshHealthData() async {
    // 건강기록 화면의 데이터를 백그라운드에서 새로고침
    try {
      final healthHomeScreenState = healthHomeScreenKey.currentState;
      if (healthHomeScreenState != null) {
        // 백그라운드에서 조용히 새로고침 수행
        await healthHomeScreenState.refreshHealthData();
      }
    } catch (e) {
      // 새로고침 실패 시 조용히 처리
      print('건강 데이터 새로고침 실패 (조용히 처리됨): $e');
    }
  }

  Future<void> _refreshHomeData() async {
    // 홈 화면의 데이터를 백그라운드에서 새로고침
    try {
      final homeScreenState = homeScreenKey.currentState;
      if (homeScreenState != null) {
        // 백그라운드에서 조용히 새로고침 수행
        await homeScreenState.refreshHomeData();
      }
    } catch (e) {
      // 새로고침 실패 시 조용히 처리
      print('홈 데이터 새로고침 실패 (조용히 처리됨): $e');
    }
  }

  Future<void> _refreshPhotoData() async {
    // 마음기록(앨범) 화면의 데이터를 백그라운드에서 새로고침
    try {
      final photoCalendarScreenState = photoCalendarScreenKey.currentState;
      if (photoCalendarScreenState != null) {
        // 백그라운드에서 조용히 새로고침 수행
        await photoCalendarScreenState.refreshPhotoCalendar();
      }
    } catch (e) {
      // 새로고침 실패 시 조용히 처리
      print('마음기록 데이터 새로고침 실패 (조용히 처리됨): $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0 || index == 1) {
      _checkHealthRecordStatus();
    }

    // 홈 탭(index=0) 선택 시 백그라운드 새로고침
    if (index == 0) {
      _refreshHomeData();
    }

    // 건강기록 탭(index=1) 선택 시 백그라운드 새로고침
    if (index == 1) {
      _refreshHealthData();
    }
    
    // 마음기록(앨범) 탭(index=2) 선택 시 백그라운드 새로고침
    if (index == 2) {
      _refreshPhotoData();
    }
  }

  Future<void> _onAddRecordTapped() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final maumLogResponse = await MaumLogService.getMaumLog(today);

      if (maumLogResponse.hasUploadedOwn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 마음 기록 완료!',
                    style: TextStyle(
                      color: AppColors.ongiOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '같은 날에는 한 번만 기록할 수 있어요.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );

          if (result == true) {
            _checkHealthRecordStatus();
          }
        }
      }
    } catch (e) {
      print('마음로그 확인 중 에러: $e');
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddRecordScreen()),
        );

        if (result == true) {
          _checkHealthRecordStatus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ongiLigntgrey,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          if (_showTooltip) _buildTooltip(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildTooltip() {
    return Positioned(
      bottom: 0,
      left: -150,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: _showTooltip ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showTooltip = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: SvgPicture.asset(
                'assets/images/record_tooltip.svg',
                width: 112,
                height: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 72, // 원래 높이로 복구
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            0,
            SvgPicture.asset(
              'assets/images/nav_Home.svg',
              width: 24,
              height: 24,
              color: _currentIndex == 0
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
            ),
            '홈',
          ),
          _buildNavItem(
            1,
            SvgPicture.asset(
              'assets/images/nav_Health.svg',
              color: _currentIndex == 1
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 32,
              height: 32,
            ),
            '건강 기록',
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(40),
              onTap: () => _onAddRecordTapped(),
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.ongiBlue, AppColors.ongiOrange],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
          _buildNavItem(
            2,
            SvgPicture.asset(
              'assets/images/nav_Commun.svg',
              color: _currentIndex == 2
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 24,
              height: 24,
            ),
            '앨범',
          ),
          _buildNavItem(
            3,
            SvgPicture.asset(
              'assets/images/nav_Mypage.svg',
              color: _currentIndex == 3
                  ? AppColors.ongiOrange
                  : Colors.grey[300]!,
              width: 24,
              height: 24,
            ),
            '마이페이지',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, Widget iconWidget, String text) {
    final isSelected = index == _currentIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onTabTapped(index),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.ongiOrange : Colors.grey[300],
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
