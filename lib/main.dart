import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman-halaman yang sudah kita buat sebelumnya
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Memastikan binding Flutter siap sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Error: $e");
  }

  runApp(StepMateApp());
}

class StepMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepMate Navigation',
      debugShowCheckedModeBanner: false,
      
      // Tema Premium: Deep Navy & Blue Accent
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent.withOpacity(0.7),
          surface: const Color(0xFF1E293B),
        ),
      ),
      
      // Jalur navigasi awal dimulai dari Splash Screen
      home: SplashScreen(),
    );
  }
}