import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Menyimpan riwayat perjalanan user
  
  Future<void> saveHistory(String userId, String destination) async {
    try {
      await _db.collection('users').doc(userId).collection('history').add({
        'destination': destination,
        'timestamp': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      print("Gagal simpan riwayat: $e");
    }
  }

  // 2. Mengambil data rute (untuk NavigationScreen)
  // Struktur: collection('routes') -> document('TOILET')
  Future<Map<String, dynamic>?> getRouteData(String target) async {
    try {
      var doc = await _db.collection('routes').doc(target.toUpperCase()).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print("Gagal ambil rute: $e");
    }
    return null;
  }

  // 3. Mengambil instruksi spesifik Beacon (opsional)
  Future<String> getBeaconInstruction(String beaconID) async {
    try {
      var doc = await _db.collection('beacons').doc(beaconID).get();
      if (doc.exists) {
        return doc.data()?['instruction'] ?? "Terus berjalan.";
      }
    } catch (e) {
      print("Error Beacon: $e");
    }
    return "Mencari sinyal...";
  }
}