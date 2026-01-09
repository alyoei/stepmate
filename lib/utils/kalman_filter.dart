class KalmanFilter {
  double _q = 0.05; // Process Noise
  double _r = 0.5;  // Measurement Noise
  double _x = 0.0;  // Value
  double _p = 1.0;  // Error
  double _k = 0.0;  // Gain

  double filter(double measurement) {
    _p = _p + _q;
    _k = _p / (_p + _r);
    _x = _x + _k * (measurement - _x);
    _p = (1 - _k) * _p;
    return _x;
  }
}