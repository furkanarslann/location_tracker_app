import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/failures/failures.dart';

class GeocodingService {
  factory GeocodingService() => _instance;
  const GeocodingService._();
  static const GeocodingService _instance = GeocodingService._();

  Future<String?> getAddressFromPosition(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      return _formatAddress(place);
    } catch (e) {
      throw UnknownFailure('Failed to get address from position: $e');
    }
  }

  String _formatAddress(Placemark place) {
    final components = <String>[];

    if (place.street?.isNotEmpty ?? false) {
      components.add(place.street!);
    }
    if (place.subLocality?.isNotEmpty ?? false) {
      components.add(place.subLocality!);
    }
    if (place.locality?.isNotEmpty ?? false) {
      components.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty ?? false) {
      components.add(place.administrativeArea!);
    }
    if (place.country?.isNotEmpty ?? false) {
      components.add(place.country!);
    }

    return components.join(', ');
  }
}
