import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:async';
import '../utils/kalman_filter.dart';

class NavigationScreen extends StatefulWidget {
  final String target;
  NavigationScreen({required this.target});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin {
  FlutterTts tts = FlutterTts();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // DOUBLE KALMAN FILTER
  
  KalmanFilter beaconKalman = KalmanFilter();
  KalmanFilter accelKalman = KalmanFilter();
  
  // State Navigasi
  String currentInstruction = "Mengambil data rute...";
  String lastInstruction = "";
  bool isUsingSensor = false;
  int stepsTaken = 0;
  List<dynamic> remoteRoute = [];

  // Controller & Subscription
  late AnimationController _pulseController;
  StreamSubscription? _beaconSubscription;
  StreamSubscription? _accelSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
    
    _fetchRouteFromFirebase();
  }

  // AMBIL DATA DARI FIREBASE (Agar dinamis)
  void _fetchRouteFromFirebase() async {
    try {
      var doc = await firestore.collection('routes').doc(widget.target.toUpperCase()).get();
      
      if (doc.exists) {
        setState(() {
          remoteRoute = doc.data()?['steps'] ?? [];
          currentInstruction = "Mencari Sinyal Beacon...";
        });
        _initNavigation();
      } else {
        setState(() => currentInstruction = "Rute tidak ditemukan.");
        tts.speak("Maaf, rute menuju ${widget.target} belum terdaftar di sistem.");
      }
    } catch (e) {
      setState(() => currentInstruction = "Gagal terhubung ke database.");
    }
  }

  void _initNavigation() async {
    await tts.setLanguage("id-ID");
    _startScanning();
  }

  void _speakInstruction(String text) async {
    if (text != lastInstruction) {
      await tts.speak(text);
      lastInstruction = text;
    }
  }

  // --- LOGIKA UTAMA: BEACON DENGAN BEACON-KALMAN ---
  void _startScanning() async {
    _speakInstruction("Mencari sinyal beacon untuk ${widget.target}. Berjalanlah perlahan.");

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    
    _beaconSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // FILTER 1: Menyaring Noise Sinyal Bluetooth
        double filteredRSSI = beaconKalman.filter(r.rssi.toDouble());

        if (mounted && !isUsingSensor) {
          setState(() {
            if (filteredRSSI > -45) {
              currentInstruction = "Tiba di lokasi. ${widget.target} ada di dekat Anda.";
            } else if (filteredRSSI > -65) {
              currentInstruction = "Sinyal kuat. Terus berjalan lurus.";
            } else {
              currentInstruction = "Sinyal terdeteksi. Silakan terus maju.";
            }
          });
          _speakInstruction(currentInstruction);
        }
      }
    });

    Future.delayed(Duration(seconds: 6), () {
      if (mounted && (lastInstruction.contains("Mencari") || currentInstruction.contains("Mengkoneksi"))) {
        _showFallbackDialog();
      }
    });
  }

  // --- LOGIKA PLAN B: SENSOR LANGKAH DENGAN ACCEL-KALMAN ---
  void _showFallbackDialog() {
    _speakInstruction("Sinyal Beacon tidak ditemukan. Gunakan mode sensor langkah?");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E293B),
        title: Text("Sinyal Lemah", style: GoogleFonts.poppins(color: Colors.white)),
        content: Text("Beacon tidak terdeteksi. Gunakan sensor langkah kaki?", 
          style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Batal", style: TextStyle(color: Colors.redAccent))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startStepNavigation();
            },
            child: Text("Ya, Gunakan Sensor"),
          ),
        ],
      ),
    );
  }

  void _startStepNavigation() {
    setState(() {
      isUsingSensor = true;
      stepsTaken = 0;
    });
    
    _speakInstruction("Mode sensor aktif. Berjalanlah sesuai instruksi suara.");

    _accelSubscription = userAccelerometerEvents.listen((event) {
      // Hitung percepatan total
      double rawAcceleration = event.x.abs() + event.y.abs() + event.z.abs();
      
      // FILTER 2: Menyaring getaran tangan yang bukan langkah kaki
      double cleanAcceleration = accelKalman.filter(rawAcceleration);

      // Deteksi hentakan kaki pada data yang sudah "bersih"
      // Angka 3.2 biasanya paling pas setelah difilter Kalman
      if (cleanAcceleration > 3.2) {
        setState(() {
          stepsTaken++;
          _updateStepInstruction();
        });
      }
    });
  }

  void _updateStepInstruction() {
    if (remoteRoute.isEmpty) return;

    for (var point in remoteRoute) {
      
      int targetStep = point['step'] is int ? point['step'] : int.parse(point['step'].toString());
      
      if (stepsTaken == targetStep) {
        setState(() {
          currentInstruction = point["msg"];
        });
        _speakInstruction(currentInstruction);
      }
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _beaconSubscription?.cancel();
    _accelSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                isUsingSensor ? "MODE SENSOR (KALMAN ON)" : "NAVIGASI BEACON (KALMAN ON)",
                style: GoogleFonts.poppins(
                  color: isUsingSensor ? Colors.greenAccent : Colors.blueAccent, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                ),
              ),
              Text(
                widget.target.toUpperCase(),
                style: GoogleFonts.exo2(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              
              Spacer(),

              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 250 * _pulseController.value,
                        height: 250 * _pulseController.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isUsingSensor ? Colors.greenAccent : Colors.blueAccent)
                                .withOpacity(1 - _pulseController.value),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E293B),
                      boxShadow: [
                        BoxShadow(
                          color: (isUsingSensor ? Colors.greenAccent : Colors.blueAccent).withOpacity(0.2), 
                          blurRadius: 40, 
                          spreadRadius: 5
                        )
                      ],
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Icon(
                      isUsingSensor ? Icons.directions_walk : Icons.navigation_rounded,
                      size: 80,
                      color: isUsingSensor ? Colors.greenAccent : Colors.blueAccent,
                    ),
                  ),
                ],
              ),

              if (isUsingSensor)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text("LANGKAH TERDETEKSI: $stepsTaken", 
                    style: GoogleFonts.poppins(color: Colors.white38, fontWeight: FontWeight.bold)),
                ),

              Spacer(),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(
                      isUsingSensor ? Icons.auto_graph : Icons.bluetooth_searching, 
                      color: Colors.blueAccent.withOpacity(0.5), 
                      size: 20
                    ),
                    SizedBox(height: 15),
                    Text(
                      currentInstruction,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton(
                  onPressed: () {
                    tts.speak("Navigasi dihentikan");
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "HENTIKAN NAVIGASI",
                    style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}