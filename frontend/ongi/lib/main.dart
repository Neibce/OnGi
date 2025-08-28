import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ongi/screens/login/login_pw_screen.dart';
import 'package:ongi/screens/splash_screen.dart';
import 'package:ongi/screens/signup/password_screen.dart';
import 'package:ongi/services/fcm_service.dart';
import 'package:ongi/services/step_service.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  messaging.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );
  
  _initializeFCMIfLoggedIn();
  _initializeHealthData();

  const categoryId = 'PILL_TAKE_REMINDER';
  final iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: [
      DarwinNotificationCategory(
        categoryId,
        actions: [
          DarwinNotificationAction.plain('ACCEPT', '복용 완료!'),
        ],
      ),
    ],
  );
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  final initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (resp) {
      switch (resp.actionId) {
        case 'ACCEPT':
          break;
      }
    }
  );

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

void _initializeHealthData() async {
  try {
    final stepService = StepService();
    final hasPermission = await stepService.requestPermissions();
    if (hasPermission) {
      print('앱 시작 시 HealthKit 권한 획득 성공');
      // 앱 시작 시 전역으로 걸음수 관찰 시작 (백그라운드 전달 등록)
      await StepService.startObserving(
        onStepsChanged: (int steps) {
          // 전역 관찰 콜백: 필요 시 로깅만 수행 (업로드는 StepService 내부에서 수행)
          print('전역 관찰: 걸음 수 변경 감지 -> $steps');
        },
      );
    } else {
      print('앱 시작 시 HealthKit 권한 획득 실패 또는 거부됨');
    }
  } catch (e) {
    print('앱 시작 시 HealthKit 초기화 오류: $e');
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
