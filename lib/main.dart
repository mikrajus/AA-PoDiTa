// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart'; // Uncomment setelah setup Firebase

import 'utils/app_theme.dart';
import 'screens/auth/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncomment setelah menambahkan google-services.json & konfigurasi Firebase:
  // await Firebase.initializeApp();

  // Status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientasi portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AAPoDiTaApp());
}

class AAPoDiTaApp extends StatelessWidget {
  const AAPoDiTaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AA-PoDiTa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LandingScreen(),
    );
  }
}
