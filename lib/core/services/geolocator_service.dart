import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
export 'package:geolocator/geolocator.dart';

class GeolocatorService {
  factory GeolocatorService() => _instance;
  const GeolocatorService._();
  static const GeolocatorService _instance = GeolocatorService._();

  Future<bool> isLocationServiceEnabled() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      return isEnabled;
    } catch (e) {
      throw UnknownFailure('Failed to check location service status: $e');
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return Geolocator.openLocationSettings();
    } catch (e) {
      throw UnknownFailure('Failed to open location settings: $e');
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return Geolocator.openAppSettings();
    } catch (e) {
      throw UnknownFailure('Failed to open app settings: $e');
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission;
    } catch (e) {
      throw UnknownFailure('Failed to check permission: $e');
    }
  }

  Future<LocationPermission> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission;
    } catch (e) {
      throw UnknownFailure('Failed to request permission: $e');
    }
  }

  Future<Position> getCurrentPosition() async {
    try {
      return Geolocator.getCurrentPosition();
    } catch (e) {
      throw UnknownFailure('Failed to get current position: $e');
    }
  }

  Stream<Position> getPositionStream() {
    try {
      return Geolocator.getPositionStream();
    } catch (e) {
      throw UnknownFailure('Failed to get position stream: $e');
    }
  }

  double calculateDistance(LatLng startPosition, LatLng endPosition) {
    try {
      return Geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        endPosition.latitude,
        endPosition.longitude,
      );
    } catch (e) {
      throw UnknownFailure('Failed to calculate distance: $e');
    }
  }
}
