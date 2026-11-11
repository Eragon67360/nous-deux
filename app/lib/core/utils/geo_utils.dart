import 'dart:math';

/// Earth radius in meters for Haversine formula.
const double _earthRadiusMeters = 6371000;

/// Returns distance in meters between two WGS84 points (Haversine).
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return _earthRadiusMeters * c;
}

double _toRad(double deg) => deg * pi / 180;

/// Threshold in meters below which we show "Ensemble" / merged marker.
const double positionMergeThresholdMeters = 10;
