import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';

abstract class MapsRepository {
  Future<LatLng> getLocation();
  Stream<LatLng> getLocationUpdates();

  Future<RouteData?> getSavedRouteData();
  Future<void> saveRouteData(RouteData routeData);
  Future<void> clearSavedRoute();

  Future<List<LatLng>> getRouteBetweenPositions({
    required LatLng source,
    required LatLng destination,
  });

  Future<double> calculateDistance(LatLng start, LatLng end);

  Future<String?> getAddressFromPosition(LatLng position);
}
