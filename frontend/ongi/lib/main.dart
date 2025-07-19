import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ongi/screens/login/login_pw_screen.dart';
import 'package:ongi/screens/start_screen.dart';
import 'package:ongi/screens/signup/password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(const OngiApp());
}

class OngiApp extends StatelessWidget {
  const OngiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ongi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Pretendard'),

      home: const StartScreen(),

      routes: {
        '/login': (context) => const LoginPwScreen(),
        '/signup': (context) => const PasswordScreen(),
      },
    );
  }
}
