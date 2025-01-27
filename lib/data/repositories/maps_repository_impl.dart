import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/core/services/geolocator_service.dart';
import 'package:location_tracker_app/core/services/route_service.dart';
import 'package:location_tracker_app/domain/repositories/maps_repository.dart';
import 'package:location_tracker_app/env.dart';
import 'package:location_tracker_app/core/services/geocoding_service.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';

class MapsRepositoryImpl implements MapsRepository {
  final RouteService routeService;
  final GeolocatorService geoLocatorService;
  final GeocodingService geocodingService;

  MapsRepositoryImpl({
    required this.routeService,
    required this.geoLocatorService,
    required this.geocodingService,
  });

  @override
  Future<LatLng> getLocation() async {
    try {
      final locationData = await geoLocatorService.getCurrentPosition().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw UnknownFailure(
              'Failed to get current location within time limit',
            ),
          );

      return LatLng(locationData.latitude, locationData.longitude);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Stream<LatLng> getLocationUpdates() async* {
    try {
      await for (final locationData in geoLocatorService.getPositionStream()) {
        yield LatLng(locationData.latitude, locationData.longitude);
      }
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> saveRouteData(RouteData routeData) async {
    try {
      await routeService.saveRouteData(routeData);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<RouteData?> getSavedRouteData() async {
    try {
      return routeService.getSavedRouteData();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> clearSavedRoute() async {
    try {
      await routeService.clearSavedRoute();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
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
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String?> getAddressFromPosition(LatLng position) async {
    try {
      return geocodingService.getAddressFromPosition(position);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<double> calculateDistance(LatLng start, LatLng end) async {
    try {
      return geoLocatorService.calculateDistance(start, end);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
