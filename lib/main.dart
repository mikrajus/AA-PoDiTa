import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/bayi_service.dart';

import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load database cache lokal terlebih dahulu
  await BayiService().initLocalDatabase();

  try {
    await Firebase.initializeApp();
    await BayiService().initFirebaseSync();
  } catch (e) {
    debugPrint(
        'Firebase belum dikonfigurasi / gagal diinisialisasi. Menggunakan penyimpanan lokal. Error: $e');
  }

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
      home: const SplashScreen(),
    );
  }
}
