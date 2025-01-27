import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/core/services/geolocator_service.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GeolocatorService geolocatorService;
  LocationRepositoryImpl({required this.geolocatorService});

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      final isLocationEnabled =
          await geolocatorService.isLocationServiceEnabled();
      return isLocationEnabled;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<LocationPermission> checkLocationPermissionStatus() async {
    try {
      final permission = await geolocatorService.checkPermission();
      return permission;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<LocationPermission> requestLocationPermission() async {
    try {
      final permission = await geolocatorService.requestPermission();
      return permission;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      final isOpened = await geolocatorService.openLocationSettings();
      return isOpened;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final isOpened = await geolocatorService.openAppSettings();
      return isOpened;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
