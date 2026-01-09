import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../utils/kalman_filter.dart';

class NavigationScreen extends StatefulWidget {
  final String target;
  NavigationScreen({required this.target});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin {
  final FlutterTts tts = FlutterTts();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final KalmanFilter beaconKalman = KalmanFilter(q: 0.01, r: 0.1); 
  final KalmanFilter accelKalman = KalmanFilter(q: 0.1, r: 0.01);
  
  String currentInstruction = "Menghubungkan ke database...";
  String lastInstruction = "";
  bool isUsingSensor = false;
  int stepsTaken = 0;
  List<dynamic> remoteRoute = [];
  bool isArrived = false;

  late AnimationController _pulseController;
  StreamSubscription? _beaconSubscription;
  StreamSubscription? _accelSubscription;
  StreamSubscription? _adapterStateSubscription; 

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Pantau status Bluetooth secara Real-time
    _monitorBluetoothStatus();
    _fetchRouteFromFirebase();
  }

  
  void _monitorBluetoothStatus() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        
        if (mounted && !isUsingSensor && !isArrived) {
          _switchToSensorMode();
        }
      }
    });
  }

  void _fetchRouteFromFirebase() async {
    try {
      var doc = await firestore.collection('routes').doc(widget.target.toUpperCase()).get();
      
      if (doc.exists) {
        setState(() {
          remoteRoute = doc.data()?['steps'] ?? [];
          currentInstruction = "Rute diterima. Mencari sinyal beacon...";
        });
        _initNavigation();
      } else {
        _handleRouteNotFound();
      }
    } catch (e) {
      setState(() => currentInstruction = "Koneksi Error: Periksa Internet");
    }
  }

  void _handleRouteNotFound() {
    setState(() => currentInstruction = "Tujuan tidak terdaftar.");
    _speakInstruction("Maaf, rute menuju ${widget.target} belum tersedia di sistem kami.");
  }

  void _initNavigation() async {
    await tts.setLanguage("id-ID");
    await tts.setPitch(1.0);
    _startScanning();
  }

  void _speakInstruction(String text) async {
    if (text != lastInstruction && text.isNotEmpty) {
      await tts.speak(text);
      lastInstruction = text;
    }
  }

  void _startScanning() async {
    
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      _switchToSensorMode();
      return;
    }

    _speakInstruction("Mencari beacon ${widget.target}. Silakan mulai berjalan.");

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    
    _beaconSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.toUpperCase().contains("BEACON") || 
            r.advertisementData.advName.toUpperCase().contains("STEPMATE")) {
          
          double filteredRSSI = beaconKalman.filter(r.rssi.toDouble());

          if (mounted && !isUsingSensor) {
            _processBeaconSignal(filteredRSSI);
          }
        }
      }
    });

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && lastInstruction.contains("Mencari") && !isArrived && !isUsingSensor) {
        _switchToSensorMode();
      }
    });
  }

  void _processBeaconSignal(double rssi) {
    setState(() {
      if (rssi > -48) {
        currentInstruction = "Tiba di lokasi. ${widget.target} tepat di depan Anda.";
        if (!isArrived) _saveTripToHistory();
      } else if (rssi > -68) {
        currentInstruction = "Sinyal kuat. Terus ikuti jalur ini.";
      } else {
        currentInstruction = "Sinyal lemah. Coba dekati area tengah ruangan.";
      }
    });
    _speakInstruction(currentInstruction);
  }

  void _switchToSensorMode() {
    
    if (isUsingSensor) return;

    _speakInstruction("Bluetooth mati atau sinyal lemah. Beralih ke mode sensor langkah.");
    setState(() {
      isUsingSensor = true;
      stepsTaken = 0;
    });

    _accelSubscription = userAccelerometerEvents.listen((event) {
      double magnitude = event.x.abs() + event.y.abs() + event.z.abs();
      double cleanAcc = accelKalman.filter(magnitude);

      if (cleanAcc > 3.2) {
        setState(() {
          stepsTaken++;
          _matchStepToRoute();
        });
      }
    });
  }

  void _matchStepToRoute() {
    if (remoteRoute.isEmpty) return;

    for (var stepData in remoteRoute) {
      int triggerStep = int.tryParse(stepData['step'].toString()) ?? 0;
      
      if (stepsTaken == triggerStep) {
        setState(() => currentInstruction = stepData["msg"]);
        _speakInstruction(currentInstruction);
        
        if (currentInstruction.toLowerCase().contains("tiba")) {
          _saveTripToHistory();
        }
      }
    }
  }

  void _saveTripToHistory() async {
    isArrived = true;
    final user = auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).collection('history').add({
        'destination': widget.target,
        'mode': isUsingSensor ? 'Sensor' : 'Beacon',
        'total_steps': stepsTaken,
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _beaconSubscription?.cancel();
    _accelSubscription?.cancel();
    _adapterStateSubscription?.cancel(); 
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          _buildBackgroundEffect(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _buildHeader(),
                const Spacer(),
                _buildCentralIcon(),
                if (isUsingSensor) _buildStepCounter(),
                const Spacer(),
                _buildInstructionCard(),
                const SizedBox(height: 30),
                _buildStopButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    return Positioned(
      top: -100,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          isUsingSensor ? "MODE SENSOR AKTIF" : "MODE BEACON AKTIF",
          style: GoogleFonts.poppins(color: isUsingSensor ? Colors.greenAccent : Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 5),
        Text(
          widget.target.toUpperCase(),
          style: GoogleFonts.exo2(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCentralIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220 * _pulseController.value,
              height: 220 * _pulseController.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: (isUsingSensor ? Colors.greenAccent : Colors.blueAccent).withOpacity(1 - _pulseController.value), width: 3),
              ),
            ),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E293B),
                boxShadow: [BoxShadow(color: (isUsingSensor ? Colors.greenAccent : Colors.blueAccent).withOpacity(0.3), blurRadius: 30)],
              ),
              child: Icon(isUsingSensor ? Icons.directions_walk : Icons.location_on, size: 70, color: isUsingSensor ? Colors.greenAccent : Colors.blueAccent),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepCounter() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Text("$stepsTaken LANGKAH", style: GoogleFonts.shareTechMono(fontSize: 24, color: Colors.white54)),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        currentInstruction,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildStopButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.redAccent)),
        ),
        child: Text("BERHENTI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
    );
  }
}