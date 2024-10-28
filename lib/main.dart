import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_management_system/LandingScreen/landing_screen.dart';
import 'package:student_management_system/LoginScreen/login_screen.dart';

import 'admin_home_screen.dart/admin_home_screen.dart';
import 'consts/constant_color.dart';
import 'firebase_options.dart';
import 'student_home_screen.dart/student_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBackGroundColor),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/adminHomeScreen': (context) => const AdminHomeScreen(),
        '/studentHomeScreen': (context) => const StudentHomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/loginscreen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LoginScreen(message: args['message']),
          );
        }
        return MaterialPageRoute(builder: (context) => const LandingScreen());
      },
    );
  }
}
