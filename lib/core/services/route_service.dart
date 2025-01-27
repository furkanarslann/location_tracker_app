import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';
export 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  final PolylinePoints _polylinePoints;
  final SharedPreferences _sharedPreferences;

  RouteService(this._polylinePoints, this._sharedPreferences);
  static const String _routeKey = 'route_data';

  Future<List<LatLng>> getRouteBetweenCoordinates({
    required PolylineRequest request,
    required String googleApiKey,
  }) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: request,
        googleApiKey: googleApiKey,
      );

      if (result.points.isEmpty) {
        throw const RouteServiceNoRoutesFailure();
      }

      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } catch (_) {
      throw const RouteServiceNoRoutesFailure();
    }
  }

  Future<void> saveRouteData(RouteData routeData) async {
    try {
      await _sharedPreferences.setString(
        _routeKey,
        json.encode(routeData.toJson()),
      );
    } catch (e) {
      throw UnknownFailure('Failed to save route data: $e');
    }
  }

  Future<RouteData?> getSavedRouteData() async {
    try {
      final jsonString = _sharedPreferences.getString(_routeKey);
      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return RouteData.fromJson(jsonMap);
    } catch (e) {
      throw UnknownFailure('Failed to load route data: $e');
    }
  }

  Future<void> clearSavedRoute() async {
    try {
      await _sharedPreferences.remove(_routeKey);
    } catch (e) {
      throw UnknownFailure('Failed to clear route data: $e');
    }
  }
}
