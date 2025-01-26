import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerData extends Equatable {
  final String id;
  final LatLng position;
  final double iconHue;
  final String title;
  final String subtitle;

  const MapMarkerData({
    required this.id,
    required this.position,
    required this.iconHue,
    required this.title,
    required this.subtitle,
  });

  factory MapMarkerData.source({
    required LatLng position,
    String? address,
  }) {
    return MapMarkerData(
      id: 'marker_source',
      position: position,
      iconHue: BitmapDescriptor.hueBlue,
      title: 'Source',
      subtitle: address ?? 'Address not found',
    );
  }

  factory MapMarkerData.destination({
    required LatLng position,
    String? address,
  }) {
    return MapMarkerData(
      id: 'marker_destination',
      position: position,
      iconHue: BitmapDescriptor.hueGreen,
      title: 'Destination',
      subtitle: address ?? 'Address not found',
    );
  }

  factory MapMarkerData.footprint({
    required LatLng position,
    String? address,
  }) {
    return MapMarkerData(
      id: 'footprint_${DateTime.now().millisecondsSinceEpoch}',
      position: position,
      iconHue: BitmapDescriptor.hueViolet,
      title: 'Footprint',
      subtitle: address ?? 'Address not found',
    );
  }

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(iconHue),
      infoWindow: InfoWindow(title: title, snippet: subtitle),
    );
  }

  @override
  List<Object> get props => [id, position, iconHue, title, subtitle];
}
