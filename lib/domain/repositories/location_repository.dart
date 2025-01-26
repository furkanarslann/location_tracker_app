import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/domain/entities/location_point_data.dart';

abstract class LocationRepository {
  Future<bool> checkLocationPermission();
  Future<LocationPointData> getLocation();
  Stream<LocationPointData> getLocationUpdates();

  Future<List<LatLng>> getSavedRoutePositions();
  Future<void> saveRoutePositions(List<LatLng> positions);
  Future<void> clearSavedRoute();

  Future<List<LatLng>> getRouteBetweenPositions({
    required LatLng source,
    required LatLng destination,
  });

  Future<String?> getAddressFromLatLng(double lat, double lng);
}
