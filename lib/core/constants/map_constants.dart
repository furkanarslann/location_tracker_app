import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  static const double defaultZoom = 14.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 20.0;
  static const LatLng defaultLocation = LatLng(41.015137, 28.979530);
  static const int locationUpdateInterval = 5000; // milliseconds
  static const double minimumDistanceThreshold = 100.0; // meters
}
