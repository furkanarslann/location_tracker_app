import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/core/services/geo_locator_service.dart';
import 'package:location_tracker_app/core/services/route_service.dart';
import 'package:location_tracker_app/domain/entities/location_point_data.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';
import 'package:location_tracker_app/env.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GeolocatorService geoLocatorService;
  final RouteService routeService;

  LocationRepositoryImpl({
    required this.geoLocatorService,
    required this.routeService,
  });

  @override
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geoLocatorService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await geoLocatorService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geoLocatorService.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    return true;
  }

  @override
  Future<LocationPointData> getLocation() async {
    log('Getting location data...', name: 'LocationRepositoryImpl');
    final locationData = await geoLocatorService.getCurrentPosition().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw LocationServiceTimeoutFailure();
      },
    );
    log('Got Location data: $locationData', name: 'LocationRepositoryImpl');
    return LocationPointData(
      position: LatLng(locationData.latitude, locationData.longitude),
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationPointData> getLocationUpdates() async* {
    try {
      await for (final locationData in geoLocatorService.getPositionStream()) {
        yield LocationPointData(
          position: LatLng(locationData.latitude, locationData.longitude),
          timestamp: DateTime.now(),
          // TODO(Furkan): implement later
          address: 'Unknown address',
        );
      }
    } catch (e) {
      throw LocationServiceFailure(e.toString());
    }
  }

  @override
  Future<void> clearSavedRoute() async {
    await routeService.clearSavedRoute();
  }

  @override
  Future<List<LatLng>> getSavedRoutePositions() async {
    return routeService.getSavedRoutePositions();
  }

  Future<void> saveRoutePositions(List<LatLng> positions) async {
    await routeService.saveRoutePositions(positions);
  }

  @override
  Future<List<LatLng>> getRouteBetweenPositions({
    required LatLng source,
    required LatLng destination,
  }) async {
    try {
      final routePositions = await routeService.getRouteBetweenCoordinates(
        googleApiKey: googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(source.latitude, source.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      return routePositions;
    } catch (e) {
      throw LocationServiceFailure('Failed to calculate route: $e');
    }
  }

  @override
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    // TODO(Furkan): Implement reverse geocoding
    return null;
  }
}
