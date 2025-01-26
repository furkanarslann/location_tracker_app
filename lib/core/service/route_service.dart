import 'package:flutter_polyline_points/flutter_polyline_points.dart';
export 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  const RouteService({required this.polylinePoints});
  final PolylinePoints polylinePoints;

  Future<PolylineResult> getRouteBetweenCoordinates({
    required PolylineRequest request,
    String? googleApiKey,
  }) async {
    return polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: googleApiKey,
    );
  }
}
