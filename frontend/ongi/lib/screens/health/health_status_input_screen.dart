import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import '../../core/app_colors.dart';
import '../../widgets/date_carousel.dart';
import '../../services/pain_service.dart';
import '../../services/health_service.dart';
import '../../services/user_service.dart';
import '../../services/family_service.dart';
import '../../utils/prefs_manager.dart';
import 'package:intl/intl.dart';

class HealthStatusInputScreen extends StatefulWidget {
  final String? selectedParentId;
  final bool? isChild;
  
  const HealthStatusInputScreen({
    super.key,
    this.selectedParentId,
    this.isChild,
  });

  @override
  State<HealthStatusInputScreen> createState() =>
      _HealthStatusInputScreenState();
}

class _HealthStatusInputScreenState extends State<HealthStatusInputScreen> {
  BodyParts _bodyParts = const BodyParts();
  DateTime selectedDate = DateTime.now();
  bool isFrontView = true;
  
  // 통증 기록 조회 관련 상태
  List<Map<String, dynamic>> _painRecords = [];
  bool _isLoadingPainRecords = false;
  bool _isInputMode = true; // true: 입력 모드, false: 조회 모드
  
  // 자녀 사용자 관련 상태
  bool _isChild = false;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void didUpdateWidget(HealthStatusInputScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 부모가 변경되었을 때 데이터 다시 로드
    if (widget.selectedParentId != oldWidget.selectedParentId) {
      setState(() {
        _selectedParentId = widget.selectedParentId;
      });
      _loadPainRecords();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다른 화면에서 돌아왔을 때 부모 목록 새로고침
    if (_isChild && mounted) {
      _refreshParentMembers();
    }
  }

  Future<void> _initializeScreen() async {
    // 이전 화면에서 전달받은 정보가 있으면 사용
    if (widget.isChild != null && widget.selectedParentId != null) {
      setState(() {
        _isChild = widget.isChild!;
        _selectedParentId = widget.selectedParentId;
      });
      
      if (_isChild) {
        await _loadParentMembers();
      } else {
        await _loadPainRecords();
      }
    } else {
      // 전달받은 정보가 없으면 기존 로직 사용
      await _checkUserType();
    }
  }

  Future<void> _checkUserType() async {
    try {
      final isParent = await PrefsManager.getIsParent();
      _isChild = !isParent;
      
      if (_isChild) {
        await _loadParentMembers();
      } else {
        await _loadPainRecords();
      }
    } catch (e) {
      print('사용자 타입 확인 실패: $e');
      await _loadPainRecords(); // 오류 시 기본 동작
    }
  }

  Future<void> _loadParentMembers() async {
    try {
      final members = await FamilyService.getFamilyMembers();
      final parents = members.where((member) => member['isParent'] == true).toList();
      
      setState(() {
        // 이전 화면에서 전달받은 selectedParentId가 없을 때만 첫 번째 부모를 기본 선택
        if (_selectedParentId == null && parents.isNotEmpty) {
          _selectedParentId = parents.first['uuid'];
        }
      });
      
      // 선택된 부모의 데이터 로드
      if (_selectedParentId != null) {
        await _loadPainRecords();
      }
    } catch (e) {
      print('부모 멤버 로드 실패: $e');
    }
  }

  // 부모 목록만 새로고침 (선택된 부모 ID 유지)
  Future<void> _refreshParentMembers() async {
    try {
      final members = await FamilyService.getFamilyMembers();
      final parents = members.where((member) => member['isParent'] == true).toList();
      
      setState(() {
        // 기존 선택된 부모가 목록에 없으면 첫 번째 부모로 변경
        if (_selectedParentId != null) {
          final selectedExists = parents.any((parent) => parent['uuid'] == _selectedParentId);
          if (!selectedExists && parents.isNotEmpty) {
            _selectedParentId = parents.first['uuid'];
          }
        } else if (parents.isNotEmpty) {
          _selectedParentId = parents.first['uuid'];
        }
      });
      
      // 선택된 부모의 데이터 로드
      if (_selectedParentId != null) {
        await _loadPainRecords();
      }
    } catch (e) {
      print('부모 멤버 새로고침 실패: $e');
    }
  }

  // 통증 기록 조회
  Future<void> _loadPainRecords() async {
    setState(() {
      _isLoadingPainRecords = true;
    });

    try {
      // 자녀인 경우 선택된 부모의 통증 기록 조회, 부모인 경우 본인 기록 조회
      String? targetUserId;
      if (_isChild) {
        targetUserId = _selectedParentId;
      } else {
        final userInfo = await PrefsManager.getUserInfo();
        targetUserId = userInfo['uuid'];
      }
      
      if (targetUserId != null) {
        final painRecords = await HealthService.fetchPainRecords(targetUserId);
        final today = selectedDate;
        final todayStr = DateFormat('yyyy-MM-dd').format(today);
        
        final todayPainRecords = painRecords
            .where((record) => record['date'] == todayStr)
            .toList();
            
        setState(() {
          _painRecords = todayPainRecords;
          _updateBodyPartsFromRecords();
        });
      }
    } catch (e) {
      print('통증 기록 조회 실패: $e');
    } finally {
      setState(() {
        _isLoadingPainRecords = false;
      });
    }
  }

  // 기록에서 BodyParts 업데이트
  void _updateBodyPartsFromRecords() {
    if (_painRecords.isEmpty) {
      setState(() {
        _bodyParts = const BodyParts();
        // 자녀인 경우 항상 읽기 전용
        _isInputMode = !_isChild;
      });
      return;
    }

    setState(() {
      // 자녀인 경우 항상 읽기 전용(조회 모드)
      _isInputMode = false;
    });

    // 통증 기록을 BodyParts로 변환
    BodyParts newBodyParts = const BodyParts();
    
    for (final record in _painRecords) {
      final painArea = record['painArea']?.toString().toLowerCase() ?? '';
      
      switch (painArea) {
        case 'head':
          newBodyParts = newBodyParts.copyWith(head: true);
          break;
        case 'neck':
          newBodyParts = newBodyParts.copyWith(neck: true);
          break;
        case 'shoulder':
          newBodyParts = newBodyParts.copyWith(
            leftShoulder: true,
            rightShoulder: true,
          );
          break;
        case 'chest':
          newBodyParts = newBodyParts.copyWith(upperBody: true);
          break;
        case 'back':
          newBodyParts = newBodyParts.copyWith(lowerBody: true);
          break;
        case 'arm':
          newBodyParts = newBodyParts.copyWith(
            leftUpperArm: true,
            rightUpperArm: true,
            leftElbow: true,
            rightElbow: true,
            leftLowerArm: true,
            rightLowerArm: true,
          );
          break;
        case 'hand':
          newBodyParts = newBodyParts.copyWith(
            leftHand: true,
            rightHand: true,
          );
          break;
        case 'abdomen':
          newBodyParts = newBodyParts.copyWith(abdomen: true);
          break;
        case 'waist':
          newBodyParts = newBodyParts.copyWith(vestibular: true);
          break;
        case 'leg':
          newBodyParts = newBodyParts.copyWith(
            leftUpperLeg: true,
            rightUpperLeg: true,
            leftLowerLeg: true,
            rightLowerLeg: true,
          );
          break;
        case 'knee':
          newBodyParts = newBodyParts.copyWith(
            leftKnee: true,
            rightKnee: true,
          );
          break;
        case 'foot':
          newBodyParts = newBodyParts.copyWith(
            leftFoot: true,
            rightFoot: true,
          );
          break;
      }
    }
    
    setState(() {
      _bodyParts = newBodyParts;
    });
  }

  // 날짜 변경 처리
  void _onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
    _loadPainRecords();
  }

  String _convertPainAreaToKorean(String painArea) {
    final painAreaMap = {
      'head': '머리',
      'neck': '목',
      'shoulder': '어깨',
      'chest': '가슴',
      'back': '등',
      'arm': '팔',
      'hand': '손',
      'abdomen': '복부',
      'waist': '허리',
      'leg': '다리',
      'knee': '무릎',
      'foot': '발',
      'none': '없음',
    };
    return painAreaMap[painArea.toLowerCase()] ?? painArea;
  }

  Widget _buildTitleText() {
    if (_painRecords.isNotEmpty) {
      final koreanAreas = _painRecords
          .map((record) => _convertPainAreaToKorean(record['painArea'].toString()))
          .where((area) => area != '없음')
          .toSet()
          .join(', ');
      
      if (koreanAreas.isNotEmpty) {
        return Column(
          children: [
            Text(
              koreanAreas,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            const Text(
              '불편해요!',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }
    }
    
    // 기본 제목 (통증 기록이 없을 때)
    if (_isChild) {
      return const Column(
        children: [
          Text(
            '통증 기록이 아직',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(
            '입력되지 않았어요!',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return const Column(
        children: [
          Text(
            '어느 곳이',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(
            '불편하세요?',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  // 신체 부위 선택 처리
  void onBodyPartsSelected(BodyParts parts) {
    // 자녀인 경우 입력 비활성화
    if (_isChild) {
      return;
    }
    
    if (!_isInputMode) {
      // 조회 모드에서 입력 모드로 전환
      setState(() {
        _isInputMode = true;
      });
    }
    setState(() {
      _bodyParts = parts;
    });
  }

  // 선택된 부위가 있는지 확인
  bool get hasSelectedParts {
    return _bodyParts.toString().contains('true');
  }

  // 앞/뒤 전환 메서드
  void toggleView() {
    setState(() {
      isFrontView = !isFrontView;
    });
  }

  List<PainArea> _getSelectedPainAreas() {
    List<PainArea> painAreas = [];

    // BodyParts를 API enum으로 매핑
    final bodyPartsString = _bodyParts.toString();

    if (bodyPartsString.contains('head: true')) painAreas.add(PainArea.head);
    if (bodyPartsString.contains('neck: true')) painAreas.add(PainArea.neck);
    if (bodyPartsString.contains('leftShoulder: true') ||
        bodyPartsString.contains('rightShoulder: true'))
      painAreas.add(PainArea.shoulder);
    if (bodyPartsString.contains('upperBody: true'))
      painAreas.add(PainArea.chest);
    if (bodyPartsString.contains('lowerBody: true'))
      painAreas.add(PainArea.back);
    if (bodyPartsString.contains('leftUpperArm: true') ||
        bodyPartsString.contains('rightUpperArm: true') ||
        bodyPartsString.contains('leftElbow: true') ||
        bodyPartsString.contains('rightElbow: true') ||
        bodyPartsString.contains('leftLowerArm: true') ||
        bodyPartsString.contains('rightLowerArm: true'))
      painAreas.add(PainArea.arm);
    if (bodyPartsString.contains('leftHand: true') ||
        bodyPartsString.contains('rightHand: true'))
      painAreas.add(PainArea.hand);
    if (bodyPartsString.contains('abdomen: true'))
      painAreas.add(PainArea.abdomen);
    if (bodyPartsString.contains('vestibular: true'))
      painAreas.add(PainArea.waist); // vestibular를 waist로 매핑
    if (bodyPartsString.contains('leftUpperLeg: true') ||
        bodyPartsString.contains('rightUpperLeg: true') ||
        bodyPartsString.contains('leftLowerLeg: true') ||
        bodyPartsString.contains('rightLowerLeg: true'))
      painAreas.add(PainArea.leg);
    if (bodyPartsString.contains('leftKnee: true') ||
        bodyPartsString.contains('rightKnee: true'))
      painAreas.add(PainArea.knee);
    if (bodyPartsString.contains('leftFoot: true') ||
        bodyPartsString.contains('rightFoot: true'))
      painAreas.add(PainArea.foot);

    // 중복 제거
    return painAreas.toSet().toList();
  }

  // 선택된 통증 부위를 한국어로 변환
  String _getPainAreaInKorean(PainArea painArea) {
    switch (painArea) {
      case PainArea.head:
        return '머리';
      case PainArea.neck:
        return '목';
      case PainArea.shoulder:
        return '어깨';
      case PainArea.chest:
        return '가슴';
      case PainArea.back:
        return '등';
      case PainArea.arm:
        return '팔';
      case PainArea.hand:
        return '손';
      case PainArea.abdomen:
        return '복부';
      case PainArea.waist:
        return '허리';
      case PainArea.leg:
        return '다리';
      case PainArea.knee:
        return '무릎';
      case PainArea.foot:
        return '발';
      case PainArea.none:
        return '없음';
    }
  }

  // 확인 다이얼로그 표시
  void showConfirmationDialog() {
    final painAreas = _getSelectedPainAreas();

    if (painAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '통증 부위를 선택해주세요.',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final koreanPainAreas = painAreas.map(_getPainAreaInKorean).toList();
    final painAreasText = koreanPainAreas.join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 닫기 버튼
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: AppColors.ongiOrange,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 선택된 부위 표시
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      color: AppColors.ongiOrange,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: painAreasText),
                      const TextSpan(text: '\n불편하신가요?'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 기록하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      submitPainRecords(); // API 호출
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ongiOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '기록하기',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 통증 기록 저장 (실제 API 호출)
  void submitPainRecords() async {
    // 토큰 확인
    final token = await PrefsManager.getAccessToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '로그인이 필요합니다. 다시 시도해주세요',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 사용자 인증 확인
    try {
      await UserService.user();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '인증이 만료되었습니다. 다시 로그인해주세요.',
                  style: TextStyle(color: AppColors.ongiOrange),
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
          action: SnackBarAction(
            label: '로그인',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    // 가족 정보 확인
    final familyInfo = await FamilyService.getFamilyInfo();

    if (familyInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.family_restroom, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('통증 기록을 위해 가족이 필요합니다'),
                    Text('가족을 생성하거나 가입해주세요.', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 8),
          action: SnackBarAction(
            label: '가족 설정',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/family');
            },
          ),
        ),
      );
      return;
    }

    final painAreas = _getSelectedPainAreas();

    // 로딩 상태 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.ongiOrange),
      ),
    );

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);

      // 여러 부위가 선택된 경우 각각 개별 API 호출
      for (final painArea in painAreas) {
        final result = await PainService.addPainRecord(
          date: dateString,
          painArea: painArea.value,
          painLevel: PainLevel.midWeak.value,
        );

        if (result == null) {
          throw Exception('통증 기록 저장에 실패했습니다.');
        }
      }

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '통증 기록이 저장되었습니다. (${painAreas.length}개 부위)',
            style: TextStyle(color: AppColors.ongiOrange),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 기록 다시 로드
      await _loadPainRecords();
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 1.56;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 상단 원형 배경
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -circleSize * 0.76),
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ongiOrange,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: circleSize * 0.86),
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          child: Column(
                            children: [
                              _buildTitleText(),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                child: Image.asset(
                                  'assets/images/sitting_mom_icon.png',
                                  width: 110,
                                  height: 110,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 본문
            Positioned(
              top: circleSize * 0.3 + 65,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: DateCarousel(
                      onDateChanged: _onDateChanged,
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                                                    child: Stack(
                              children: [
                                if (_isLoadingPainRecords)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.ongiOrange,
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: BodyPartSelector(
                                      bodyParts: _bodyParts,
                                      onSelectionUpdated: onBodyPartsSelected,
                                      side: isFrontView
                                          ? BodySide.front
                                          : BodySide.back,
                                      selectedColor: AppColors.ongiOrange,
                                      unselectedColor: AppColors.ongiGrey,
                                      selectedOutlineColor: Colors.white,
                                      unselectedOutlineColor: Colors.white,
                                    ),
                                  ),
                            // 기록완료 버튼 (부모인 경우만 표시)
                            if (!_isChild)
                              Positioned(
                                right: 16,
                                top: 16,
                                child: GestureDetector(
                                  onTap: hasSelectedParts
                                      ? showConfirmationDialog
                                      : null,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasSelectedParts
                                          ? AppColors.ongiOrange
                                          : Colors.grey[300],
                                      border: Border.all(
                                        color: hasSelectedParts
                                            ? AppColors.ongiOrange
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '완료',
                                        style: TextStyle(
                                          color: hasSelectedParts
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // 앞뒤 전환 버튼 (오른쪽 하단)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFrontView
                                      ? Colors.white
                                      : AppColors.ongiOrange,
                                  border: Border.all(
                                    color: AppColors.ongiOrange,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: toggleView,
                                  child: Center(
                                    child: Text(
                                      isFrontView ? '앞' : '뒤',
                                      style: TextStyle(
                                        color: isFrontView
                                            ? AppColors.ongiOrange
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
