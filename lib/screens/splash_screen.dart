import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  _initAndNavigate() async {
    await tts.setLanguage("id-ID");
    await tts.speak("Selamat datang di Step Mate. Teman setia navigasi indoor Anda.");
    
    await Future.delayed(Duration(seconds: 4));
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.near_me_rounded, size: 100, color: Colors.blueAccent),
            SizedBox(height: 24),
            Text("STEPMATE", 
              style: GoogleFonts.exo2(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 8)),
            SizedBox(height: 10),
            Text("INDOOR NAVIGATION", 
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueAccent, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}