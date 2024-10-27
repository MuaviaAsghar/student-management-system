import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management_system/LandingScreen/landing_screen.dart';
import 'package:student_management_system/LoginScreen/login_screen.dart';

import 'consts/constant_color.dart';
import 'firebase_options.dart';
import 'helpers/error_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ErrorProvider>(create: (_) => ErrorProvider()),
        // Add other providers here if necessary
      ],
      child: const MyApp(),
    ),
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
      onGenerateRoute: (settings) {
        if (settings.name == '/loginscreen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LoginScreen(message: args['message']),
          );
        }

        // Default route (LandingScreen)
        return MaterialPageRoute(builder: (context) => const LandingScreen());
      },
    );
  }
}
