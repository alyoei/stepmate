import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/kalman_filter.dart';

class NavigationScreen extends StatefulWidget {
  final String target;
  NavigationScreen({required this.target});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  FlutterTts tts = FlutterTts();
  KalmanFilter kalman = KalmanFilter();
  String currentInstruction = "Mencari sinyal...";
  
  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() async {
    await tts.speak("Navigasi ke ${widget.target} dimulai. Berjalanlah perlahan.");
    
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Logika Filter Sinyal
        double filteredRSSI = kalman.filter(r.rssi.toDouble());
        
        setState(() {
          if (filteredRSSI > -50) {
            currentInstruction = "Hampir sampai di ${widget.target}.";
          } else {
            currentInstruction = "Berjalan lurus ke arah depan.";
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 100, color: Colors.blueAccent),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                currentInstruction,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("HENTIKAN NAVIGASI"),
            )
          ],
        ),
      ),
    );
  }
}