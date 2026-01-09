import 'dart:math';
import '../utils/kalman_filter.dart';

class NavigationEngine {
  final Map<String, KalmanFilter> _filters = {};

  // Menghitung estimasi jarak berdasarkan RSSI
  double calculateDistance(int rssi, int txPower) {
    if (rssi == 0) return -1.0;
    
    // N = konstanta lingkungan indoor (2.0 - 4.0)
    double n = 2.5; 
    return pow(10, ((txPower - rssi) / (10 * n))).toDouble();
  }

  double getFilteredRSSI(String deviceId, int rawRSSI) {
    _filters.putIfAbsent(deviceId, () => KalmanFilter());
    return _filters[deviceId]!.filter(rawRSSI.toDouble());
  }
}