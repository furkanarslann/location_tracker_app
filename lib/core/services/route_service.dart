import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  final PolylinePoints polylinePoints;
  final SharedPreferences sharedPreferences;

  static const String _routePositionsKey = 'route_positions';

  RouteService({required this.polylinePoints, required this.sharedPreferences});

  Future<List<LatLng>> getRouteBetweenCoordinates({
    required PolylineRequest request,
    required String googleApiKey,
  }) async {
    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: googleApiKey,
    );

    return result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<void> saveRoutePositions(List<LatLng> positions) async {
    final jsonList = positions.map((position) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }).toList();

    await sharedPreferences.setString(
      _routePositionsKey,
      json.encode(jsonList),
    );
  }

  Future<List<LatLng>> getSavedRoutePositions() async {
    final jsonString = sharedPreferences.getString(_routePositionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) {
        final Map<String, dynamic> position = Map<String, dynamic>.from(json);
        return LatLng(
          position['latitude'] as double,
          position['longitude'] as double,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSavedRoute() async {
    await sharedPreferences.remove(_routePositionsKey);
  }
}
