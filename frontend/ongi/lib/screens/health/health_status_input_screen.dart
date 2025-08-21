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

  // 가슴과 등만 별도로 관리하는 상태
  bool _chestSelected = false;
  bool _backSelected = false;

  // 통증 기록 조회 관련 상태
  List<Map<String, dynamic>> _painRecords = [];
  bool _isLoadingPainRecords = false;
  bool _isInputMode = true; // true: 입력 모드, false: 조회 모드

  // 자녀 사용자 관련 상태
  bool _isChild = false;
  String? _selectedParentId;

  //스트레칭 버튼 표시 여부
  bool _isiStrechingVisible = false;

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
      _isiStrechingVisible = false;
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
          _isiStrechingVisible = true;
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
        // 가슴/등 상태 초기화
        _chestSelected = false;
        _backSelected = false;
        // 자녀인 경우 항상 읽기 전용
        _isInputMode = !_isChild;
      });
      return;
    }

    setState(() {
      // 자녀인 경우 항상 읽기 전용(조회 모드)
      _isInputMode = false;
    });

    BodyParts newBodyParts = const BodyParts();

    // 가슴/등 상태 초기화
    _chestSelected = false;
    _backSelected = false;

    for (final record in _painRecords) {
      final painArea = record['painArea']?.toString().toLowerCase() ?? '';

      switch (painArea) {
        case 'head':
          newBodyParts = newBodyParts.copyWith(head: true);
          break;
        case 'neck':
          newBodyParts = newBodyParts.copyWith(neck: true);
          break;
        case 'left_shoulder':
          newBodyParts = newBodyParts.copyWith(leftShoulder: true);
          break;
        case 'right_shoulder':
          newBodyParts = newBodyParts.copyWith(rightShoulder: true);
          break;
        case 'chest':
        // 가슴은 별도 상태로 관리
          _chestSelected = true;
          break;
        case 'back':
        // 등은 별도 상태로 관리
          _backSelected = true;
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

    // 현재 뷰에 따라 가슴/등 표시
    _updateBodyPartsDisplay();
  }

  // 현재 뷰에 따라 가슴/등 표시 업데이트
  void _updateBodyPartsDisplay() {
    setState(() {
      if (isFrontView) {
        // 앞면: 가슴 선택 상태만 반영
        _bodyParts = _bodyParts.copyWith(upperBody: _chestSelected);
      } else {
        // 뒷면: 등 선택 상태만 반영
        _bodyParts = _bodyParts.copyWith(upperBody: _backSelected);
      }
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
      'HEAD': '머리',
      'NECK': '목',
      'LEFT_SHOULDER': '왼쪽 어깨',
      'RIGHT_SHOULDER': '오른쪽 어깨',
      'CHEST': '가슴',
      'BACK': '등',
      'LEFT_UPPER_ARM': '왼쪽 윗팔',
      'RIGHT_UPPER_ARM': '오른쪽 윗팔',
      'LEFT_FOREARM': '왼쪽 아랫팔',
      'RIGHT_FOREARM': '오른쪽 아랫팔',
      'LEFT_HAND': '왼쪽 손',
      'RIGHT_HAND': '오른쪽 손',
      'ABDOMEN': '복부',
      'WAIST': '허리',
      'PELVIS': '골반',
      'HIP': '엉덩이',
      'LEFT_THIGH': '왼쪽 허벅지',
      'RIGHT_THIGH': '오른쪽 허벅지',
      'LEFT_CALF': '왼쪽 종아리',
      'RIGHT_CALF': '오른쪽 종아리',
      'LEFT_KNEE': '왼쪽 무릎',
      'RIGHT_KNEE': '오른쪽 무릎',
      'LEFT_FOOT': '왼쪽 발',
      'RIGHT_FOOT': '오른쪽 발',
      'NONE': '없음',
    };
    return painAreaMap[painArea.toUpperCase()] ?? painArea;
  }

  void showStretchingDialog() {
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
                Text(
                  painAreasText,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildTitleText() {
    if (_painRecords.isNotEmpty) {
      for (var record in _painRecords) {
        print('디버깅 - painArea 원본: ${record['painArea']}');
        print('디버깅 - painArea 타입: ${record['painArea'].runtimeType}');
        print('디버깅 - 한글 변환: ${_convertPainAreaToKorean(record['painArea'].toString())}');
      }

      final koreanAreas = _painRecords
          .expand((record) {
        final painArea = record['painArea'];
        if (painArea is List) {
          // painArea가 List인 경우 각 항목을 변환
          return painArea.map((area) => _convertPainAreaToKorean(area.toString()));
        } else {
          // painArea가 단일 값인 경우
          return [_convertPainAreaToKorean(painArea.toString())];
        }
      })
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

    // 가슴/등 선택 상태 업데이트 (앞/뒤 구분)
    final partsString = parts.toString();
    final upperBodySelected = partsString.contains('upperBody: true');

    if (isFrontView) {
      // 앞면에서는 가슴만 선택/해제
      _chestSelected = upperBodySelected;
      // 뒷면 선택은 유지
    } else {
      // 뒷면에서는 등만 선택/해제
      _backSelected = upperBodySelected;
      // 앞면 선택은 유지
    }

    // upperBody 제외하고 다른 부위들만 업데이트
    BodyParts updatedParts = parts.copyWith(upperBody: false);

    setState(() {
      _bodyParts = updatedParts;
      // 현재 뷰에 맞는 가슴/등 표시 업데이트
      _updateBodyPartsDisplay();
    });
  }

  // 선택된 부위가 있는지 확인
  bool get hasSelectedParts {
    return _bodyParts.toString().contains('true') || _chestSelected || _backSelected;
  }

  // 앞/뒤 전환 메서드
  void toggleView() {
    setState(() {
      isFrontView = !isFrontView;
    });
    // 뷰 전환 시 가슴/등 표시 업데이트
    _updateBodyPartsDisplay();
  }

  List<PainArea> _getSelectedPainAreas() {
    List<PainArea> painAreas = [];

    final bodyPartsString = _bodyParts.toString();

    if (bodyPartsString.contains('head: true'))
      painAreas.add(PainArea.head);
    if (bodyPartsString.contains('neck: true'))
      painAreas.add(PainArea.neck);

    // 어깨
    if (bodyPartsString.contains('leftShoulder: true'))
      painAreas.add(PainArea.rightShoulder);
    if (bodyPartsString.contains('rightShoulder: true'))
      painAreas.add(PainArea.leftShoulder);

    // 가슴과 등을 별도 상태로 확인
    if (_chestSelected)
      painAreas.add(PainArea.chest);
    if (_backSelected)
      painAreas.add(PainArea.back);

    // 팔
    if (bodyPartsString.contains('leftUpperArm: true'))
      painAreas.add(PainArea.rightUpperArm);
    if (bodyPartsString.contains('rightUpperArm: true'))
      painAreas.add(PainArea.leftUpperArm);
    if (bodyPartsString.contains('leftLowerArm: true'))
      painAreas.add(PainArea.rightForearm);
    if (bodyPartsString.contains('rightLowerArm: true'))
      painAreas.add(PainArea.leftForearm);

    // 손
    if (bodyPartsString.contains('leftHand: true'))
      painAreas.add(PainArea.rightHand);
    if (bodyPartsString.contains('rightHand: true'))
      painAreas.add(PainArea.leftHand);

    if (bodyPartsString.contains('abdomen: true'))
      painAreas.add(PainArea.abdomen);

    // 허리/골반/엉덩이 (vestibular 속성)
    if (bodyPartsString.contains('vestibular: true')) {
      painAreas.add(PainArea.waist);
      painAreas.add(PainArea.pelvis);
      painAreas.add(PainArea.hip);
    }

    // 다리
    if (bodyPartsString.contains('leftUpperLeg: true'))
      painAreas.add(PainArea.rightThigh);
    if (bodyPartsString.contains('rightUpperLeg: true'))
      painAreas.add(PainArea.leftThigh);
    if (bodyPartsString.contains('leftLowerLeg: true'))
      painAreas.add(PainArea.rightCalf);
    if (bodyPartsString.contains('rightLowerLeg: true'))
      painAreas.add(PainArea.leftCalf);

    // 무릎
    if (bodyPartsString.contains('leftKnee: true'))
      painAreas.add(PainArea.rightKnee);
    if (bodyPartsString.contains('rightKnee: true'))
      painAreas.add(PainArea.leftKnee);

    // 발
    if (bodyPartsString.contains('leftFoot: true'))
      painAreas.add(PainArea.rightFoot);
    if (bodyPartsString.contains('rightFoot: true'))
      painAreas.add(PainArea.leftFoot);

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
      case PainArea.leftShoulder:
        return '왼쪽 어깨';
      case PainArea.rightShoulder:
        return '오른쪽 어깨';
      case PainArea.chest:
        return '가슴';
      case PainArea.back:
        return '등';
      case PainArea.leftUpperArm:
        return '왼쪽 윗팔';
      case PainArea.rightUpperArm:
        return '오른쪽 윗팔';
      case PainArea.leftForearm:
        return '왼쪽 아랫팔';
      case PainArea.rightForearm:
        return '오른쪽 아랫팔';
      case PainArea.leftHand:
        return '왼쪽 손';
      case PainArea.rightHand:
        return '오른쪽 손';
      case PainArea.abdomen:
        return '복부';
      case PainArea.waist:
        return '허리';
      case PainArea.pelvis:
        return '골반';
      case PainArea.hip:
        return '엉덩이';
      case PainArea.leftThigh:
        return '왼쪽 허벅지';
      case PainArea.rightThigh:
        return '오른쪽 허벅지';
      case PainArea.leftCalf:
        return '왼쪽 종아리';
      case PainArea.rightCalf:
        return '오른쪽 종아리';
      case PainArea.leftKnee:
        return '왼쪽 무릎';
      case PainArea.rightKnee:
        return '오른쪽 무릎';
      case PainArea.leftFoot:
        return '왼쪽 발';
      case PainArea.rightFoot:
        return '오른쪽 발';
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
  Widget _buildStretchingButton() {
    return Visibility(
      // visible: _isStretchingVisible, // _isStretchingVisible 값에 따라 버튼 표시 여부 결정
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 스트레칭 안내 텍스트 추가
              const Text(
                '통증이 완화될 수 있도록',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Text(
                '스트레칭 해볼까요?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              // 스트레칭 하러 가기 버튼
              ElevatedButton(
                onPressed: showStretchingDialog, // 버튼을 누르면 다이얼로그 표시
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ongiOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  '스트레칭 하러 가기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

      // 선택된 모든 부위를 한 번에 API 호출 (List로 전송)
      final painAreaValues = painAreas.map((area) => area.value).toList();
      print('통증 기록 저장 시도: 날짜=$dateString, 부위들=$painAreaValues');

      final result = await PainService.addPainRecord(
        date: dateString,
        painAreas: painAreaValues,  // List로 전송, painLevel 제거
      );

      print('통증 기록 저장 결과: $result');

      if (result == null) {
        throw Exception('통증 기록 저장에 실패했습니다. 부위들: $painAreaValues');
      }

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '통증 기록이 저장되었습니다. (${painAreas.length}개 부위)',
            style: const TextStyle(color: AppColors.ongiOrange),
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
      print('통증 기록 저장 중 오류 발생: $e');

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '통증 기록 저장 실패: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          duration: const Duration(seconds: 5),
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
                  if(_isiStrechingVisible) _buildStretchingButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
