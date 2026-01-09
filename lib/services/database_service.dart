import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final _db = FirebaseDatabase.instance.ref();

  // Menyimpan riwayat perjalanan user
  Future<void> saveHistory(String userId, String destination) async {
    await _db.child('history').child(userId).push().set({
      'destination': destination,
      'timestamp': ServerValue.timestamp,
    });
  }

  // Mengambil data instruksi beacon dari cloud
  // Struktur di Firebase: beacons -> BEACON_LOBBY -> instruction: "Belok kanan..."
  Future<String> getInstruction(String beaconName) async {
    DataSnapshot snapshot = await _db.child('beacons').child(beaconName).get();
    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      return data['instruction'] ?? "Berjalanlah perlahan.";
    }
    return "Terus berjalan.";
  }
}