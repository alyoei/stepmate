class KalmanFilter {
  // Q (Process Noise): Seberapa besar kita percaya pada perubahan sistem itu sendiri.
  // Nilai kecil (0.01) = Hasil sangat mulus tapi lambat merespon perubahan cepat.
  double _q; 
  
  // R (Measurement Noise): Seberapa besar kita percaya pada sensor (RSSI/Akselerometer).
  // Nilai besar (0.1 - 0.5) = Kita kurang percaya sensor karena banyak gangguan (noise).
  double _r; 
  
  double _x = 0.0; // Estimasi nilai saat ini
  double _p = 1.0; // Estimasi error (ketidakpastian)
  double _k = 0.0; // Kalman Gain (bobot antara sensor vs prediksi)

  // Constructor agar nilai Q dan R bisa diatur berbeda untuk tiap sensor
  KalmanFilter({double q = 0.01, double r = 0.1}) : _q = q, _r = r;

  double filter(double measurement) {
    // 1. Prediction Update
    _p = _p + _q;

    // 2. Measurement Update (Koreksi)
    _k = _p / (_p + _r); // Menghitung bobot (Gain)
    _x = _x + _k * (measurement - _x); // Memperbarui estimasi dengan data baru
    _p = (1 - _k) * _p; // Memperbarui ketidakpastian

    return _x;
  }
}