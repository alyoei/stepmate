import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:app_stepmate/screens/splash_screen.dart';
import 'package:app_stepmate/screens/login_screen.dart';
import 'package:app_stepmate/screens/register_screen.dart';
import 'package:app_stepmate/screens/home_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  try {
    await Firebase.initializeApp();
    print("✅ Firebase inisialisasi berhasil.");
  } catch (e) {
    print("❌ Firebase inisialisasi error: $e");
  }

  runApp(StepMateApp());
}

class StepMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepMate Indoor Navigation',
      debugShowCheckedModeBanner: false,
      
      
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: Colors.blueAccent,
        
      
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        
        
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent.withOpacity(0.8),
          surface: const Color(0xFF1E293B),
        ),
      ),

      
      home: SplashScreen(),

   
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}