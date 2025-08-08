import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static const _accessTokenKey = 'accessToken';
  static const _userNameKey = 'userName';
  static const _userFamilyCodeKey = 'userFamilyCode';
  static const _userFamilyNameKey = 'userFamilyName';
  static const _isParent = 'isParent';
  static const _userProfileImageKey = 'userProfileImage';
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

  static Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userNameKey);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await _prefs;
    return {
      'name': prefs.getString(_userNameKey),
      'uuid': prefs.getString(_uuidKey),
      'familycode': prefs.getString(_userFamilyCodeKey),
      'familyname': prefs.getString(_userFamilyNameKey),
      'profileImage': prefs.getString(_userProfileImageKey),
      'isParent': prefs.getBool(_isParent) == true ? 'true' : 'false',
    };
  }

  static Future<void> saveFamilyCodeAndName(String code, String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userFamilyCodeKey, code);
    await prefs.setString(_userFamilyNameKey, name);
  }
}
