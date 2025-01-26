import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';
export 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  final PolylinePoints polylinePoints;
  final SharedPreferences sharedPreferences;
  static const String _routeKey = 'route_data';

  RouteService({
    required this.polylinePoints,
    required this.sharedPreferences,
  });

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

  Future<void> saveRouteData(RouteData routeData) async {
    await sharedPreferences.setString(
      _routeKey,
      json.encode(routeData.toJson()),
    );
  }

  Future<RouteData?> getSavedRouteData() async {
    final jsonString = sharedPreferences.getString(_routeKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return RouteData.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSavedRoute() async {
    await sharedPreferences.remove(_routeKey);
  }
}
