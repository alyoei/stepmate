import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart'; 
import 'navigation_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterTts tts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  String wordsSpoken = "";
  
 
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSpeech();
  }

  _initTTS() async {
    await tts.setLanguage("id-ID");
    
    String nama = user?.displayName ?? "Pengguna";
    await tts.speak("Halo $nama, selamat datang di Halaman utama. Ketuk tombol besar di tengah untuk mulai mencari tujuan.");
  }

  _initSpeech() async {
    await speech.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: (val) => print('Status: $val'),
    );
  }

  void _startVoiceSearch() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        await tts.speak("Silakan sebutkan tujuan Anda.");

        speech.listen(
          localeId: "id_ID",
          onResult: (val) {
            setState(() {
              wordsSpoken = val.recognizedWords;
              if (val.finalResult) {
                _processVoiceCommand(wordsSpoken);
              }
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  void _processVoiceCommand(String command) async {
    setState(() => isListening = false);
    
    if (command.isNotEmpty) {
      
      await tts.speak("Mencari rute menuju $command. Rute ditemukan. Membuka navigasi.");
      
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => NavigationScreen(target: command))
          );
        }
      });
    } else {
      await tts.speak("Maaf, saya tidak mendengar tujuan Anda. Silakan coba lagi.");
    }
  }

  @override
  Widget build(BuildContext context) {
    
    String firstName = user?.displayName?.split(' ')[0] ?? "User";

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1E293B), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      
                        Text("Halo, $firstName", 
                          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("StepMate siap memandu Anda", 
                          style: GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFF1E293B),
                          
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null ? Icon(Icons.person, color: Colors.white) : null,
                        ),
                      ),
                    )
                  ],
                ),
                
                Spacer(),

                if (isListening)
                  Text(
                    wordsSpoken.isEmpty ? "Mendengarkan..." : wordsSpoken,
                    style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                SizedBox(height: 20),

                GestureDetector(
                  onTap: _startVoiceSearch,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildPulseEffect(isListening),
                      Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E293B),
                          boxShadow: [
                            BoxShadow(
                              color: isListening ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 10,
                            )
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isListening ? Icons.graphic_eq : Icons.mic_rounded, 
                              size: 80, 
                              color: isListening ? Colors.greenAccent : Colors.white
                            ),
                            SizedBox(height: 15),
                            Text(
                              isListening ? "MENDENGAR..." : "CARI TUJUAN",
                              style: GoogleFonts.poppins(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 12
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
                Text(
                  "Ketuk lingkaran untuk mencari dengan suara",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                ),

                Spacer(),
                
                
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildQuickAction(Icons.history, "Tujuan Terakhir: Menunggu Data..."),
                      Divider(color: Colors.white10),
                      _buildQuickAction(Icons.star_border_rounded, "Simpan Lokasi Baru"),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
  Widget _buildPulseEffect(bool isActive) {
    if (!isActive) return SizedBox();
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: 1.5),
      duration: Duration(seconds: 1),
      builder: (context, double value, child) {
        return Container(
          width: 220 * value,
          height: 220 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isListening ? Colors.greenAccent : Colors.blueAccent).withOpacity(1.5 - value),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }

  Widget _buildQuickAction(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          SizedBox(width: 15),
          Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          Spacer(),
          Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }
}