import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ongi/screens/login/login_pw_screen.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/screens/signup/password_screen.dart';
import 'package:ongi/screens/bottom_nav.dart';
import 'package:ongi/utils/prefs_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  runApp(const OngiApp());
}

class OngiApp extends StatefulWidget {
  const OngiApp({super.key});

  @override
  State<OngiApp> createState() => _OngiAppState();
}

class _OngiAppState extends State<OngiApp> {
  Widget _homeWidget = const StartScreen();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final hasToken = await PrefsManager.hasAccessToken();

    setState(() {
      _homeWidget = hasToken ? const BottomNavScreen() : const StartScreen();
    });

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ongi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Pretendard'),

      home: _homeWidget,

      routes: {
        '/login': (context) => const LoginPwScreen(),
        '/signup': (context) => const PasswordScreen(),
      },
    );
  }
}
