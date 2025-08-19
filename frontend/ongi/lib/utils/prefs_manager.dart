import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static const _accessTokenKey = 'accessToken';
  static const _userNameKey = 'userName';
  static const _userFamilyCodeKey = 'userFamilyCode';
  static const _userFamilyNameKey = 'userFamilyName';
  static const _isParent = 'isParent';
  static const _profileImageIdKey = 'profileImageId';
  static const _uuidKey = 'uuid';

  static SharedPreferences? _instance;

  static Future<SharedPreferences> get _prefs async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> clearAccessToken() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  static Future<bool> hasAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey) != null;
  }

  static Future<void> saveUuid(String uuid) async {
    final prefs = await _prefs;
    await prefs.setString(_uuidKey, uuid);
  }

  static Future<String?> getUuid() async {
    final prefs = await _prefs;
    return prefs.getString(_uuidKey);
  }

  static Future<void> saveProfileImageId(int profileImageId) async {
    final prefs = await _prefs;
    await prefs.setInt(_profileImageIdKey, profileImageId);
  }

  static Future<int?> getProfileImageId() async {
    final prefs = await _prefs;
    return prefs.getInt(_profileImageIdKey);
  }

  static Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_uuidKey);
    await prefs.remove(_userFamilyCodeKey);
    await prefs.remove(_userFamilyNameKey);
    await prefs.remove(_profileImageIdKey);
    await prefs.remove(_isParent);
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await _prefs;
    return {
      'name': prefs.getString(_userNameKey),
      'uuid': prefs.getString(_uuidKey),
      'familycode': prefs.getString(_userFamilyCodeKey),
      'familyname': prefs.getString(_userFamilyNameKey),
      'profileImageId': prefs.getInt(_profileImageIdKey),
      'isParent': prefs.getBool(_isParent) == true ? 'true' : 'false',
    };
  }

  static Future<void> saveFamilyCodeAndName(String code, String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userFamilyCodeKey, code);
    await prefs.setString(_userFamilyNameKey, name);
  }

  static Future<void> saveIsParent(bool isParent) async {
    final prefs = await _prefs;
    await prefs.setBool(_isParent, isParent);
  }

  static Future<bool> getIsParent() async {
    final prefs = await _prefs;
    return prefs.getBool(_isParent) ?? false;
  }

  // 프로필 이미지 인덱스를 실제 이미지 경로로 변환하는 함수
  static String getProfileImagePath(int index) {
    final imagePaths = [
      'assets/images/users/mom_icon.png',      // 0
      'assets/images/users/dad_icon.png',      // 1
      'assets/images/users/daughter_icon.png', // 2
      'assets/images/users/son_icon.png',      // 3
      'assets/images/users/black_woman_icon.png', // 4
      'assets/images/users/black_man_icon.png',   // 5
      'assets/images/users/baby_icon.png',     // 6
      'assets/images/users/dog_icon.png',      // 7
      'assets/images/users/robot_icon.png',    // 8
    ];
    
    if (index >= 0 && index < imagePaths.length) {
      return imagePaths[index];
    }
    // 기본값으로 첫 번째 이미지 반환
    return imagePaths[0];
  }

  // userId를 기반으로 프로필 이미지 경로를 가져오는 함수
  static Future<String> getProfileImagePathByUserId(String userId, List<Map<String, dynamic>> familyMembers) async {
    try {
      // familyMembers에서 userId와 일치하는 구성원 찾기
      final member = familyMembers.firstWhere(
        (member) => member['userId']?.toString() == userId,
        orElse: () => <String, dynamic>{},
      );
      
      // profileImageId가 있으면 해당 이미지 경로 반환
      if (member.isNotEmpty && member['profileImageId'] != null) {
        final profileImageId = member['profileImageId'] as int;
        return getProfileImagePath(profileImageId);
      }
      
      // 현재 사용자인지 확인해서 현재 사용자 프로필 이미지 반환
      final currentUserInfo = await getUserInfo();
      final currentUserUuid = currentUserInfo['uuid'];
      if (userId == currentUserUuid) {
        final profileImageId = currentUserInfo['profileImageId'] ?? 0;
        return getProfileImagePath(profileImageId);
      }
      
      // 기본 이미지 반환
      return getProfileImagePath(0);
    } catch (e) {
      // 에러 발생 시 기본 이미지 반환
      return getProfileImagePath(0);
    }
  }

  // userName을 기반으로 프로필 이미지 경로를 가져오는 함수
  static Future<String> getProfileImagePathByUserName(String userName, List<Map<String, dynamic>> familyMembers) async {
    try {
      // familyMembers에서 userName과 일치하는 구성원 찾기
      final member = familyMembers.firstWhere(
        (member) => member['name']?.toString() == userName,
        orElse: () => <String, dynamic>{},
      );
      
      // profileImageId가 있으면 해당 이미지 경로 반환
      if (member.isNotEmpty && member['profileImageId'] != null) {
        final profileImageId = member['profileImageId'] as int;
        return getProfileImagePath(profileImageId);
      }
      
      // 현재 사용자인지 확인해서 현재 사용자 프로필 이미지 반환
      final currentUserInfo = await getUserInfo();
      final currentUserName = currentUserInfo['name'];
      if (userName == currentUserName) {
        final profileImageId = currentUserInfo['profileImageId'] ?? 0;
        return getProfileImagePath(profileImageId);
      }
      
      // 기본 이미지 반환
      return getProfileImagePath(0);
    } catch (e) {
      // 에러 발생 시 기본 이미지 반환
      return getProfileImagePath(0);
    }
  }
}
