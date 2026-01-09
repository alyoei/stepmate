import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'login_screen.dart';
import 'home_screen.dart'; 

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  FlutterTts tts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initAndNavigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  _initAndNavigate() async {
    
    await tts.setLanguage("id-ID");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5); 
    await tts.speak("Selamat datang di Step Mate. Teman setia navigasi indoor Anda.");
    
    
    await Future.delayed(Duration(seconds: 4));

    if (mounted) {
      
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => HomeScreen())
        );
      } else {
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => LoginScreen())
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: _buildCircle(400, Colors.blueAccent.withOpacity(0.05)),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildCircle(300, Colors.indigo.withOpacity(0.1)),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.near_me_rounded, 
                        size: 80, 
                        color: Colors.white
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "STEPMATE", 
                      style: GoogleFonts.exo2(
                        fontSize: 40, 
                        fontWeight: FontWeight.w800, 
                        color: Colors.white, 
                        letterSpacing: 10,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "INDOOR NAVIGATION", 
                      style: GoogleFonts.poppins(
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                        color: Colors.blueAccent.withOpacity(0.8), 
                        letterSpacing: 4
                      ),
                    ),
                    SizedBox(height: 60),
                    SizedBox(
                      width: 40,
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}