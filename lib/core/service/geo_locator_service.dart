import 'package:geolocator/geolocator.dart';
export 'package:geolocator/geolocator.dart';

class GeolocatorService {
  factory GeolocatorService() => _instance;
  const GeolocatorService._();
  static const GeolocatorService _instance = GeolocatorService._();

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }
}
