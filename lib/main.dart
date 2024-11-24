import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:student_management_system/LandingScreen/landing_screen.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

import 'LoginScreen/login_screen.dart';
import 'admin_home_screen.dart/admin_home_screen.dart';
import 'consts/constant_color.dart';
import 'firebase_options.dart';
import 'helpers/update_data_provider.dart';
import 'student_home_screen.dart/student_home_screen.dart';
import 'student_home_screen.dart/update_data_page.dart';
import 'student_register_page/add_profile_picture.dart';
import 'student_register_page/student_registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Supabase.initialize(
  //   url: 'https://phedmgxterrgpfadtaqx.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoZWRtZ3h0ZXJyZ3BmYWR0YXF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA0MzcyMjIsImV4cCI6MjA0NjAxMzIyMn0.eL6ZCzsfPbvNRJF83eG6s1hkREGqLArGhZr8Z_agil4',
  // );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('loginBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MaterialApp(
        title: 'Student Management System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kBackGroundColor),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/adminHomeScreen': (context) => const AdminHomeScreen(),
          '/studentHomeScreen': (context) => const StudentHomeScreen(),
          '/studentRegistrationScreen': (context) =>
              const StudentRegistrationScreen(),
          '/addProfilePicture': (context) => const AddProfilePictureScreen(),
          '/updateDataScreen': (context) => const UpdateDataPage()
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/loginscreen') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                message: args['message'],
                showRegister: args['showRegister'] ?? false,
              ),
            );
          }
          return MaterialPageRoute(builder: (context) => const LandingScreen());
        },
      ),
    );
  }
}
