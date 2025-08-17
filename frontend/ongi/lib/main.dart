import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ongi/screens/login/login_pw_screen.dart';
import 'package:ongi/screens/splash_screen.dart';
import 'package:ongi/screens/signup/password_screen.dart';
import 'package:ongi/services/fcm_service.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  _initializeFCMIfLoggedIn();

  runApp(const OngiApp());
}

void _initializeFCMIfLoggedIn() async {
  try {
    final hasToken = await PrefsManager.hasAccessToken();
    if (hasToken) {
      await FCMService.initializeAndUploadFCMToken();
    }
  } catch (e) {
    print('앱 시작 시 FCM 초기화 중 오류: $e');
  }
}

class OngiApp extends StatelessWidget {
  const OngiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ongi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Pretendard'),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPwScreen(),
        '/signup': (context) => const PasswordScreen(),
      },
    );
  }
}
