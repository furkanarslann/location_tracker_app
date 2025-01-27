import 'package:location_tracker_app/core/services/geolocator_service.dart';

abstract class LocationRepository {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkLocationPermissionStatus();
  Future<LocationPermission> requestLocationPermission();
  Future<bool> openLocationSettings();
  Future<bool> openAppSettings();
}
